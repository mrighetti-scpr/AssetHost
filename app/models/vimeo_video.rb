class VimeoVideo < Video
  self.table_name = "asset_host_core_vimeo_videos"

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

