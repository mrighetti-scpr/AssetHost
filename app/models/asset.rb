class Asset < ActiveRecord::Base
  self.table_name = "asset_host_core_assets"

  attr_accessor :image, :file

  @queue = :paperclip

  VIA_UNKNOWN   = 0
  VIA_FLICKR    = 1
  VIA_LOCAL     = 2
  VIA_UPLOAD    = 3

  GRAVITY_OPTIONS = [
    [ "Center (default)", "Center"    ],
    [ "Top",              "North"     ],
    [ "Bottom",           "South"     ],
    [ "Left",             "West"      ],
    [ "Right",            "East"      ],
    [ "Top Left",         "NorthWest" ],
    [ "Top Right",        "NorthEast" ],
    [ "Bottom Left",      "SouthWest" ],
    [ "Bottom Right",     "SouthEast" ]
  ]

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  index_name AssetHostCore.config.elasticsearch_index

  scope :visible, -> { where(is_hidden: false) }

  has_many :outputs, -> { order("created_at desc").distinct }, :class_name => "AssetOutput", :dependent => :destroy
  belongs_to :native, :polymorphic => true  # again, this is just for things like youtube videos

  before_create :sync_exif_data

  after_create :save_image

  after_commit :publish_asset_update, :if => :persisted?
  after_commit :publish_asset_delete, :on => :destroy


  def self.es_search(query,options={})
    es_q = {
      function_score: {
        query: { query_string: { query:query, default_operator:"AND" } },
        functions: [
          {
            gauss: {
              taken_at: {
                origin: Time.zone.now.iso8601,
                scale:  "26w",
                offset: "13w",
                decay:  0.8
              }
            }
          },
          {
            gauss: {
              long_edge: {
                origin: 4200,
                scale:  300,
                offset: 3000,
                decay:  0.7
              }
            }
          }
        ]
      }
    }

    #Rails.logger.info "ES Query is: #{ es_q.to_json() }"

    assets = []
    Asset.search(query:es_q).page(options[:page]||1).per(options[:per_page]||24).records
  end



  def size(code)
    @_sizes ||= {}
    @_sizes[ code ] ||= AssetSize.new(self, Output.where(code: code).first)
  end


  def image
    #HACK
    # Here, we're shimming the Paperclip attachment so that
    # important methods for generating #as_json still function.
    #
    # We should work to do away with this entirely if Paperclip
    # is otherwise doing nothing.
    @_image ||= Paperclip::Attachment.new 'image', self 
  end


  def as_json(options={})
    #:url        => "http://#{AssetHostCore.config.server}#{AssetHostCore::Engine.mounted_path}/api/assets/#{self.id}/",
    {
      :id                 => self.id,
      :title              => self.title,
      :caption            => self.caption,
      :owner              => self.owner,
      :size               => [self.image_width, self.image_height].join('x'),
      :tags               => self.image.tags,
      :notes              => self.notes,
      :created_at         => self.created_at,
      :taken_at           => self.image_taken || self.created_at,
      :native             => self.native.try(:as_json),
      # Native only applies to something like a youtube video
      # don't worry about it.
      :image_file_size    => self.image_file_size,
      :url        => "http://localhost:9000/api/assets/#{self.id}/",
      :sizes      => Output.paperclip_sizes.inject({}) { |h, (s,_)| h[s] = { width: self.image.width(s), height: self.image.height(s) }; h },
      :urls       => Output.paperclip_sizes.inject({}) { |h, (s,_)| h[s] = self.image_url(s); h }
    }.merge(self.image_shape())
  end

  alias :json :as_json

  def image_data= data

    if data[:fingerprint]
      self.image_fingerprint = data[:fingerprint]
    end

    # -- determine metadata -- #
    begin
      if p = data[:metadata]
        if p.credit =~ /Getty Images/
          # smart import for Getty Images photos
          copyright     = [p.by_line,p.credit].join("/")
          title         = p.headline
          description   = p.description

        elsif p.credit =~ /AP/
          # smart import for AP photos
          copyright     = [p.by_line,p.credit].join("/")
          title         = p.title
          description   = p.description

        else
          copyright     = p.byline || p.credit
          title         = p.title
          description   = p.description
        end
        self.image_width       = p.image_width
        self.image_height      = p.image_height
        self.image_title       = title
        self.image_description = description
        self.image_copyright   = copyright
        self.image_taken       = p.datetime_original
        self.keywords          = (p.keywords || []).map(&:downcase).join(", ")
      end

      true
    rescue => e
      # a failure to parse metadata
      # should not crash everything 
      puts e
      false
    end

    self.keywords = (keywords || "").split(/,\s*/).concat(data[:keywords].map{|label| label.name.downcase }).join(", ")

  end



  def image_shape
    if !self.image_width || !self.image_height
      return {
        orientation: nil,
        long_edge: 0,
        short_edge: 0,
        ratio: 0
      }
    end

    if ( self.image_width > self.image_height )
      orientation = :landscape
      long_edge   = self.image_width
      short_edge  = self.image_height
    else
      orientation = :portrait
      long_edge   = self.image_height
      short_edge  = self.image_width
    end

    if ( long_edge - short_edge ) < long_edge * 0.1
      orientation = :square
    end

    {
      orientation:  orientation,
      long_edge:    long_edge,
      short_edge:   short_edge,
      ratio:        (long_edge.to_f / short_edge).round(3)
    }
  end

  def file_key style='original'
    # if id && image_fingerprint && image_content_type
    #   extension = Rack::Mime::MIME_TYPES.invert[image_content_type]
    #   "#{id}_#{image_fingerprint}_#{style}#{extension}"
    # end
    # ^^ I was thinking we might need to retrieve based on
    # content type, but apparently this is not the case.
    if id && image_fingerprint
      "#{id}_#{image_fingerprint}_#{style}.jpg"
    end
  end

  def image_url(style)
    # "http://#{config.assethost.server}/i/:fingerprint/:id-:style.:extension"

    style = style.to_sym

    ext = nil
    begin
      # FIXME: Need to add correct extension
      ext = case style
      when :original
        File.extname(self.image.original_filename).gsub(/^\.+/, "")
      else
        Output.paperclip_sizes[style][:format]
      end
    rescue => e
      binding.pry
    end

    "http://localhost:9000/i/#{self.image_fingerprint}/#{self.id}-#{style}.#{ext}"
  end



  def as_indexed_json(options={})
    # ^^ options?
    {
      :id               => self.id,
      :title            => self.title,
      :caption          => self.caption,
      :keywords         => self.keywords,
      :owner            => self.owner,
      :notes            => self.notes,
      :created_at       => self.created_at,
      :taken_at         => self.image_taken || self.created_at,
      :image_file_size  => self.image_file_size,
      :native_type      => self.native_type,
      :hidden           => self.is_hidden,
    }.merge(self.image_shape())
  end



  def shape
    if !self.image_width || !self.image_height
      :unknown
    elsif self.image_width == self.image_height
      :square
    elsif self.image_width > self.image_height
      :landscape
    else
      :portrait
    end
  end



  def tag(style)
    self.image.tag(style)
  end



  def isPortrait?
    self.image_width < self.image_height
  end



  def url_domain
    return nil if !self.url

    domain = URI.parse(self.url).host
    domain == 'www.flickr.com' ? 'Flickr' : domain
  end



  def output_by_style(style)
    @s_outputs ||= self.outputs.inject({}) { |h,o| h[o.output.code] = o; h }
    @s_outputs[style.to_s] || false
  end

  def rendered_outputs
    @rendered ||= Output.paperclip_sizes.collect do |s|
      ["#{s[0]} (#{self.image.width(s[0])}x#{self.image.height(s[0])})",s[0]]
    end
  end



  def self.interpolate(pattern, attachment, style)
    # we support:
    # global:
    #   :rails_root -- Rails.root
    #
    # style-based:
    #   :style -- output code
    #   :extension -- extension for Output
    #
    # asset-based:
    #   :id -- asset id
    #   :fingerprint -- image fingerprint
    #
    # output-based:
    #   :sprint -- AssetOutput fingerprint
    #
    # first see what we've been passed as a style. could be string, symbol,
    # Output or AssetOutput

    asset   = attachment.instance
    result  = pattern.clone

    if style.respond_to?(:to_sym) && style.to_sym == :original
      # special case...

    elsif style.is_a? AssetOutput
      ao      = style
      output  = ao.output

    elsif style.is_a? Output
      output  = style
      ao      = attachment.instance.outputs.where(output_id: output.id).first
      return nil if !ao

    else
      output = Output.where(code: style).first
      return nil if !output

      ao = attachment.instance.outputs.where(output_id: output.id).first
    end


    # global rules
    result.gsub!(":rails_root", Rails.root.to_s)

    if asset
      # asset-based rules
      result.gsub!(":id", asset.id.to_s)
      result.gsub!(":fingerprint", asset.image_fingerprint.to_s)
    else
      if pattern =~ /:(?:id|fingerprint)/
        return false
      end
    end

    if style.respond_to?(:to_sym) && style.to_sym == :original
      # hardcoded handling for the original file
      result.gsub!(":style", "original")
      result.gsub!(":extension", File.extname(attachment.original_filename).gsub(/^\.+/, ""))
      result.gsub!(":sprint","original")
    else
      if output
        # style-based rules
        result.gsub!(":style", output.code.to_s)
        result.gsub!(":extension", output.extension)
      else
        if pattern =~ /:(?:style|extension)/
          return false
        end
      end


      if ao && ao.fingerprint
        # output-based rules
        result.gsub!(":sprint", ao.fingerprint)
      else
        result.gsub!(":sprint", "NOT_YET_RENDERED")
      end
    end

    result
  end


  # syncs the exif to the corresponding Asset attributes
  # We don't want to override anything that was set explicitly.
  def sync_exif_data
    self.title     = self.image_title       if self.title.blank?
    self.caption   = self.image_description if self.caption.blank?
    self.owner     = self.image_copyright   if self.owner.blank?
  end



  def method_missing(method, *args)
    if output = Output.where(code: method.to_s).first
      self.size(output.code)
    else
      super
    end
  end

  private

  def save_image
    uploader = PhotographicMemory.new Aws::S3::Resource.new.bucket('assethost-dev')
    self.image_data = uploader.put file: file, id: self.id, style_name: 'original', content_type: "image/jpeg"
    self.save
    # ^^ ingests the fingerprint, exif metadata, and anything else we get back from the render result
  end

  def publish_asset_update
    AssetHost::Application.redis_publish(action: "UPDATE", id: self.id)
    # true
  end

  def publish_asset_delete
    AssetHost::Application.redis_publish(action: "DELETE", id: self.id)
    # true
  end
end

#----------

class AssetSize
  attr_accessor  :width, :height, :tag, :url, :asset, :output

  def initialize(asset,output)
    @asset  = asset
    @output = output

    @width    = @asset.image.width(output.code_sym)
    @height   = @asset.image.height(output.code_sym)
    @url      = @asset.image_url(output.code_sym)
    @tag      = @asset.image.tag(output.code_sym)
  end
end

