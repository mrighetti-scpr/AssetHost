module AssetHostCore
  class VimeoVideo < Video
    def attrs
      {
        "data-assethost"  => "VimeoVideo",
        "data-ah-videoid" => self.videoid
      }
    end

    def as_json
      {
        :class    => "VimeoVideo",
        :videoid  => self.videoid
      }
    end
  end
end
