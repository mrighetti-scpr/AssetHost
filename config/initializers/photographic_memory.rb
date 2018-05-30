class PhotographicMemory
  def self.create
    PhotographicMemory.new({
      environment:                   Rails.env,
      s3_bucket:                     Rails.application.secrets.s3[:bucket],
      s3_region:                     Rails.application.secrets.s3[:region],
      s3_endpoint:                   Rails.application.secrets.s3[:endpoint],
      s3_access_key_id:              Rails.application.secrets.s3[:access_key_id],
      s3_secret_access_key:          Rails.application.secrets.s3[:secret_access_key],
      rekognition_region:            Rails.application.secrets.rekognition[:region],
      rekognition_access_key_id:     Rails.application.secrets.rekognition[:access_key_id],
      rekognition_secret_access_key: Rails.application.secrets.rekognition[:secret_access_key]
    })
  end
end