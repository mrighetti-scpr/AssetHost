class BrightcoveVideo < Video
  field :length, type: Integer

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

