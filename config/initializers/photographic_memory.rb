class PhotographicMemory
  def self.create
    PhotographicMemory.new({
      environment:                   Rails.env,
      s3_bucket:                     ENV["ASSETHOST_S3_BUCKET"],
      s3_region:                     ENV["ASSETHOST_S3_REGION"],
      s3_endpoint:                   ENV["ASSETHOST_S3_ENDPOINT"],
      s3_access_key_id:              ENV["ASSETHOST_S3_ACCESS_KEY_ID"],
      s3_secret_access_key:          ENV["ASSETHOST_S3_SECRET_ACCESS_KEY"],
      rekognition_region:            ENV["ASSETHOST_REKOGNITION_REGION"],
      rekognition_access_key_id:     ENV["ASSETHOST_REKOGNITION_ACCESS_KEY_ID"],
      rekognition_secret_access_key: ENV["ASSETHOST_REKOGNITION_SECRET_ACCESS_KEY"]
    })
  end
end