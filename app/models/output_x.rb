##
# Determines how assets are rendered based on provided rules.
##

class OutputX

  include Mongoid::Document

  CONTENT_TYPES = ["image/jpeg", "image/png", "image/gif"]

  field :name,           type: String
  field :render_options, type: Array,   default: []
  field :prerender,      type: Boolean, default: false
  field :content_type,   type: String
  field :created_at,     type: DateTime
  field :updated_at,     type: DateTime

  validates :name, uniqueness: true, presence: true
  # validate  :check_extension

  index name: 1

  scope :prerenderers, -> { where(prerender: true) }

  def convert_arguments
    args = []
    (self.render_options || []).each do |o|
      operation  = OpenStruct.new(o)
      properties = OpenStruct.new(operation.properties || {})
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
    output = ActiveSupport::HashWithIndifferentAccess.new({ width: width, height: height})
    scale  = ActiveSupport::HashWithIndifferentAccess.new(render_options.find{|o| o["name"] == "scale"} || { properties: {} })
    crop   = ActiveSupport::HashWithIndifferentAccess.new(render_options.find{|o| o["name"] == "crop"}  || { properties: {} })
    output["width"]  = [scale["properties"]["width"],  crop["properties"]["width"]].compact.min  || width
    output["height"] = [scale["properties"]["height"], crop["properties"]["height"]].compact.min || height
    output
  end

  def as_json arg
    json = super
    json.delete("_id")
    json["id"] = self.id.to_s
    json
  end
  
  private

  def check_extension
    return if !self.extension
    errors.add(:extension, "File extension not supported.") if CONTENT_TYPES.none?{|e| e == self.extension}
  end
end

