module AssetHostUtils
  class << self
    def guess_content_type filename
      extension = filename.split('.').last
      {
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'gif' => 'image/gif',
        'png' => 'image/png'
      }[extension]
    end
  end
end