##
# Determines how assets are rendered based on provided rules.
##

class Output

  include Mongoid::Document
  include Mongoid::Timestamps

  CONTENT_TYPES = ["image/jpeg", "image/png", "image/gif"]

  field :name,           type: String
  field :render_options, type: Array,   default: []
  field :prerender,      type: Boolean, default: false
  field :content_type,   type: String

  before_validation :nullify_blank_content_type

  validates :name, uniqueness: true, presence: true
  validate  :check_content_type

  index name: 1

  scope :prerenderers, -> { where(prerender: true) }

  def self.all_sizes
    self.all.map(&:name)
  end

  def convert_arguments
    args = []
    (self.render_options || []).each do |o|
      operation  = OpenStruct.new(o)
      properties = operation.properties.is_a?(Hash) ? operation.properties : (operation.properties || []).inject({}){|result, p| result[p[0]] = p[1]; result; }
      properties = OpenStruct.new(properties)
      if operation.name == "scale"
        args << "-scale #{properties.width}x#{properties.height}^"
      end
      if operation.name == "crop"
        args << "-crop #{properties.width}x#{properties.height}+#{properties.offsetX}+#{properties.offsetY} +repage"
      end
      if operation.name == "quality"
        args << "-quality #{properties.value}"
      end
    end
    args.join(" ")
  end

  ##
  # Predicts the size of a rendered image for the output with a given width and height
  ##
  def calculate_size width, height
    output = ActiveSupport::HashWithIndifferentAccess.new({ width: width, height: height })
    scale  = ActiveSupport::HashWithIndifferentAccess.new(render_options.find{|o| o["name"] == "scale"} || { properties: {} })
    s_width  = scale["properties"]["width"]
    s_height = scale["properties"]["height"]
    if scale["properties"]["maintainRatio"] && s_width && s_height
      s_width  = (s_height * (width.to_f / height.to_f)).round
      s_height = (s_width  * (height.to_f / width.to_f)).round
    end
    crop = ActiveSupport::HashWithIndifferentAccess.new(render_options.find{|o| o["name"] == "crop"}  || { properties: {} })
    output["width"]  = [s_width,  crop["properties"]["width"],  width].compact.min
    output["height"] = [s_height, crop["properties"]["height"], height].compact.min
    output
  end

  def as_json arg
    json = super
    json.delete("_id")
    json["id"] = self.id.to_s
    json
  end
  
  private

  def nullify_blank_content_type
    if self.content_type && self.content_type.empty?
      self.content_type = nil
    end
  end

  def check_content_type
    return if !self.content_type
    errors.add(:content_type, "Content type not supported.") if CONTENT_TYPES.none?{|e| e == self.content_type}
  end
end

