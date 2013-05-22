module AssetHostCore
  class YoutubeVideo < Video
    def attrs
      {
        "data-assethost"  => "YoutubeVideo",
        "data-ah-videoid" => self.videoid
      }
    end
    
    def as_json
      {
        :class    => "YoutubeVideo",
        :videoid  => self.videoid
      }
    end
  end
end
