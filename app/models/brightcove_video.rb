class BrightcoveVideo < Video
  self.table_name = "asset_host_core_brightcove_videos"

  attr_accessible :length

  def attrs
    {
      "data-assethost"  => "BrightcoveVideo", # The native client class
      "data-ah-videoid" => self.videoid
    }
  end

  def as_json
    {
      :class    => "BrightcoveVideo",
      :videoid  => self.videoid,
      :length   => self.length
    }
  end
end

