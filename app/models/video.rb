class Video
  include Mongoid::Document

  field :videoid, type: String

  embedded_in :asset, class_name: "Asset"
end

