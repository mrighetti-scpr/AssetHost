class Rendering

  include Mongoid::Document

  field :name,             type: String
  field :fingerprint,      type: String
  field :width,            type: Integer
  field :height,           type: Integer
  field :should_prerender, type: Boolean
  field :content_type,     type: String, default: "image/jpeg"
  field :created_at,       type: DateTime
  field :updated_at,       type: DateTime

  validates :name, uniqueness: true, presence: true

  embedded_in :asset, class_name: "Asset"

  def should_prerender
    self.name == "original" || super
  end

  def file_extension
    Rack::Mime::MIME_TYPES.invert[self.content_type || "image/jpeg"].gsub(".", "")
  end

  def render
    return if !self.asset || fingerprint.present?
    if should_prerender || Resque.workers.empty?
      RenderJob.perform_now(self.asset.id.to_s, self.name)
    else
      RenderJob.perform_later(self.asset.id.to_s, self.name)
    end
  end

end

