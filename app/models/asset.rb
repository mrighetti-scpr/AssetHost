class Asset
  attr_accessor :image, :file, :request

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  
  field :title,              type: String
  field :caption,            type: String
  field :owner,              type: String
  field :url,                type: String
  field :notes,              type: String
  field :image_file_name,    type: String
  field :image_content_type, type: String
  field :image_copyright,    type: String
  field :image_description,  type: String
  field :image_title,        type: String
  field :image_updated_at,   type: DateTime
  field :image_gravity,      type: String, default: "Center"
  field :image_width,        type: Integer
  field :image_height,       type: Integer
  field :image_file_size,    type: Integer
  field :image_taken,        type: DateTime
  field :keywords,           type: String
  field :version,            type: Integer, default: 2
  field :native,             type: Hash

  embeds_many :renderings, class_name: "Rendering"

  searchkick index_name: Rails.application.config.elasticsearch_index

  before_save :reload_image, if: -> {
    !new? && self.image_fingerprint && image_gravity_changed? && !@reloading
  }

  after_save :replace_original_image, if: -> { self.file && !@reloading }

  before_destroy -> { renderings.each(&:destroy) }

  def self.es_search(query=nil, page: 1, per_page: 24)
    Asset.search(query, boost_by_distance: {
      taken_at: {
        origin: Time.zone.now.iso8601,
        scale: '26w',
        offset: '13w',
        decay: 0.8
      },
      long_edge: {
        origin: 4200,
        scale: 300,
        offset: 3000,
        decay: 0.7
      }
    }, page: page, per_page: per_page)
  end

  def as_json(options={})
    {
      :id                 => self.id.to_s,
      :title              => self.title,
      :caption            => self.caption,
      :owner              => self.owner,
      :size               => [self.image_width, self.image_height].join('x'),
      :image_gravity      => self.image_gravity,
      :image_fingerprint  => self.image_fingerprint,
      :tags               => self.tags,
      :keywords           => self.keywords,
      :notes              => self.notes,
      :created_at         => self.created_at,
      :taken_at           => self.image_taken || self.created_at,
      :native             => self.native.try(:as_json),
      # Native only applies to something like a youtube video
      # don't worry about it.
      :image_file_size    => self.image_file_size,
      :url        => "#{host}/api/assets/#{self.id}/",
      :sizes      => self.sizes,
      :urls       => Output.all_sizes.inject({}) { |h, (s,_)| h[s] = self.image_url(s); h }
    }.merge(self.image_shape())
  end

  alias :json :as_json

  def sizes
    return {} if self.image_width.nil? || self.image_height.nil?
    Output.all.inject({}) do |result, output|
      code = output.name.to_sym
      result[code] = output.calculate_size(self.image_width, self.image_height)
      result
    end
  end

  def tags
    result = {}
    self.sizes.each do |pair|
      result[pair[0]] = %Q(<img src="#{self.image_url(pair[0])}" width="#{pair[1]["width"]}" height="#{pair[1]["height"]}" alt="#{self.title.to_s.gsub('"', ERB::Util::HTML_ESCAPE['"'])}" />).html_safe
    end
    result
  end

  def image_fingerprint
    # Gets the fingerprint of the "original" rendering.
    self.renderings.where(name: "original").first.try(:fingerprint)
  end

  ##
  # Ingests data from post-render
  ##
  def image_data= data

    begin
      if p = data[:metadata]
        self.image_width       = p.image_width
        self.image_height      = p.image_height
        self.image_title       = [p.title, p.headline].compact.join(" - ")
        self.image_description = p.description
        self.image_copyright   = [p.by_line, (p.owner_name || p.credit)].compact.join("/")
        self.image_taken       = p.datetime_original
        self.keywords          = (p.keywords || "").split(", ").map(&:downcase).join(", ")
      end
      true
    rescue => e
      # a failure to parse metadata
      # should not crash everything 
      false
    end

    self.keywords       = (keywords || "").split(/,\s*/).concat((data[:keywords] || []).map{|label| label.name.downcase }).join(", ")
    self.image_gravity  = data[:gravity] ? data[:gravity] : self.image_gravity
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

  def file_key rendering_name
    rendering = self.renderings.find_or_create_by(name: rendering_name)
    rendering.file_key
  end

  def file_extension
    Rack::Mime::MIME_TYPES.invert[image_content_type].try(:gsub, ".", "")
  end

  def image_url style
    return if !self.image_fingerprint
    style = style.to_sym
    ext   = case style
            when :original
              file_extension
            else
              rendering = self.renderings.where(name: style).first_or_initialize.file_extension 
              rendering || file_extension || "jpg"
            end
    "#{host}/i/#{self.image_fingerprint}/#{self.id}-#{style}.#{ext}"
  end

  def as_indexed_json
    {
      :id               => self.id.to_s,
      :title            => self.title,
      :caption          => self.caption,
      :keywords         => self.keywords,
      :owner            => self.owner,
      :notes            => self.notes,
      :created_at       => self.created_at,
      :taken_at         => self.image_taken || self.created_at,
      :image_file_size  => self.image_file_size
    }.merge(self.image_shape())
  end

  alias_method :search_data, :as_indexed_json

  # syncs the exif to the corresponding Asset attributes
  # We don't want to override anything that was set explicitly.
  def sync_exif_data
    self.title     = self.image_title       if self.title.blank?
    self.caption   = self.image_description if self.caption.blank?
    self.owner     = self.image_copyright   if self.owner.blank?
  end

  private

  def new?
    !self.id || !(self.changes["_id"] || [])[0]
  end

  def host
    return "" if !@request
    port   = ((@request.port === 80) || (@request.port === 443)) ? "" : ":#{@request.port}"
    "#{@request.protocol}#{@request.host}#{port}"
  end

  def replace_original_image
    # If you want the asset to render or re-render, all you have to do
    # is place a File or StringIO object in the file attribute
    return if !file
    self.renderings.destroy_all
    self.image_data = RenderJob.perform_now(self.id.to_s, "original", file)
    prerender file
    self.file = nil
    sync_exif_data
    self.save
    @reloading = false
  end

  def prerender file=nil
    return if !image_fingerprint
    Output.prerenderers.each do |output|
      next if output.name == "original"
      RenderJob.perform_now(self.id.to_s, output.name, file)
    end
  end

  def reload_image
    @reloading = true
    # pulls the original image from storage
    rendering = self.renderings.first_or_create(name: "original")
    self.file = AssetHostCore::Renderer.get self.file_key(rendering.name)
  end

end


