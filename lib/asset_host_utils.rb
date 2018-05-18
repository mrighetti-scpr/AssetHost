module AssetHostUtils
  class << self
    def guess_content_type filename
      # 🚨 There's now a superior version of what this function does
      #    in the Asset model, so eventually migrate that code to here.
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