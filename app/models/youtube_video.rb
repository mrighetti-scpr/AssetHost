class YoutubeVideo < Video
  self.table_name = "asset_host_core_youtube_videos"

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
