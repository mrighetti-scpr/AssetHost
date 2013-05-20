module AssetHostCore
  class Asset < ActiveRecord::Base
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


    define_index do
      indexes title
      indexes caption
      indexes notes
      indexes owner
      has created_at
      has updated_at
      where "is_hidden = 0"
    end


    scope :visible, -> { where(is_hidden: false) }

    has_many :outputs, :class_name => "AssetOutput", :order => "created_at desc", :dependent => :destroy
    belongs_to :native, :polymorphic => true

    has_attached_file :image, Rails.application.config.assethost.paperclip_options.merge({
      :styles       => proc { Output.paperclip_sizes },
      :processors   => [:asset_thumbnail],
      :interpolator => self 
    })

    treat_as_image_asset :image

    before_create :sync_exif_data

    after_commit :publish_asset_update, :if => :persisted?
    after_commit :publish_asset_delete, :on => :destroy


    attr_accessible :title,
      :caption,
      :owner,
      :url,
      :notes,
      :creator_id,
      :image,
      :image_taken,
      :native


    #----------
    
    def size(code)
      @_sizes ||= {}
      @_sizes[ code ] ||= AssetSize.new(self, Output.where(code: code).first)
    end

    #----------

    def as_json(options={})
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
        :image_file_size    => self.image_file_size,

        :url        => "http://#{Rails.application.config.assethost.server}#{AssetHostCore::Engine.mounted_path}/api/assets/#{self.id}/",
        :sizes      => Output.paperclip_sizes.inject({}) { |h, (s,_)| h[s] = { width: self.image.width(s), height: self.image.height(s) }; h },
        :urls       => Output.paperclip_sizes.inject({}) { |h, (s,_)| h[s] = self.image.url(s); h }
      }
    end

    alias :json :as_json

    #----------
    
    def tag(style)
      self.image.tag(style)
    end
    
    #----------

    def isPortrait?
      self.image_width < self.image_height
    end

    #----------

    def url_domain 
      return nil if !self.url
      
      domain = URI.parse(self.url).host
      domain == 'www.flickr.com' ? 'Flickr' : domain
    end

    #----------

    def output_by_style(style)
      @s_outputs ||= self.outputs.inject({}) { |h,o| h[o.output.code] = o; h }
      @s_outputs[style.to_s] || false
    end

    def rendered_outputs
      @rendered ||= Output.paperclip_sizes.collect do |s|
        ["#{s[0]} (#{self.image.width(s[0])}x#{self.image.height(s[0])})",s[0]]
      end
    end
    
    #----------
    
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

    #----------
    # syncs the exif to the corresponding Asset attributes
    def sync_exif_data
      self.title     = self.image_title       if self.title.blank?
      self.caption   = self.image_description if self.caption.blank?
      self.owner     = self.image_copyright   if self.owner.blank?
    end

    #----------

    def method_missing(method, *args)
      if output = Output.where(code: method.to_s).first
        self.size(output.code)
      else
        super
      end
    end


    #----------
    
    private

    def publish_asset_update
      AssetHostCore::Engine.redis_publish(action: "UPDATE", id: self.id)
      true
    end
    
    def publish_asset_delete
      AssetHostCore::Engine.redis_publish(action: "DELETE", id: self.id)
      true
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
      @url      = @asset.image.url(output.code_sym)
      @tag      = @asset.image.tag(output.code_sym)
    end
  end
end
