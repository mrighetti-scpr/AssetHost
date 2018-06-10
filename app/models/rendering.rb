class Rendering

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,             type: String
  field :fingerprint,      type: String
  field :width,            type: Integer
  field :height,           type: Integer
  field :should_prerender, type: Boolean
  field :content_type,     type: String, default: "image/jpeg"

  validates :name, uniqueness: true, presence: true

  embedded_in :asset, class_name: "Asset"

  before_destroy :delete_file

  def should_prerender
    self.name == "original" || super
  end

  def file_extension
    Rack::Mime::MIME_TYPES.invert[self.content_type || "image/jpeg"].gsub(".", "")
  end

  def file_key
    id = self.asset.try(:id)
    if id && self.fingerprint && self.file_extension
      "#{id}_#{self.fingerprint}.#{self.file_extension}"
    end
  end

  def render
    return if !self.asset || fingerprint.present?
    if should_prerender || Resque.workers.empty?
      RenderJob.perform_now(self.asset.id.to_s, self.name)
    else
      RenderJob.perform_later(self.asset.id.to_s, self.name)
    end
  end

  def delete_file
    PhotographicMemory.create.delete(file_key)
  end

end

