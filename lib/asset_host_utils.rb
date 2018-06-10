module AssetHostUtils
  class << self
    def guess_content_type filename
      extension = filename.split('.').last
      Rack::Mime::MIME_TYPES[".#{extension.downcase}"]
    end
  end
end