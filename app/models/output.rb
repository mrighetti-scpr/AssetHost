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

  def calculate_size width, height
    result = ActiveSupport::HashWithIndifferentAccess.new({ width: width, height: height })

    scale  = ActiveSupport::HashWithIndifferentAccess.new(self.render_options.find{|o| o["name"] == "scale"} || { properties: [] })
    s_properties = (scale["properties"] || [])
    s_width  = (s_properties.find{|p| p["name"] == "width" }  || {})["value"]
    s_height = (s_properties.find{|p| p["name"] == "height" } || {})["value"]
    maintain_ratio = (s_properties.find{|p| p["name"] == "maintainRatio"} || {})["value"]
    if maintain_ratio && s_width && s_height
      s_width  = (s_height.to_f * (width.to_f / height.to_f)).round
      s_height = (s_width.to_f  * (height.to_f / width.to_f)).round
    end

    crop = ActiveSupport::HashWithIndifferentAccess.new(render_options.find{|o| o["name"] == "crop"}  || { properties: [] })
    c_properties = (crop["properties"] || [])
    c_width  = (c_properties.find{|p| p["name"] == "width"}  || {})["value"]
    c_height = (c_properties.find{|p| p["name"] == "height"} || {})["value"]

    result["width"]  = [s_width,  c_width,  width].compact.map(&:to_f).min
    result["height"] = [s_height, c_height, height].compact.map(&:to_f).min
    result
  end


  def as_json *args
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

