Aws.config.update({
  region: 'us-west-1', 
  credentials: Aws::Credentials.new(Rails.application.secrets.s3['access_key'], Rails.application.secrets.s3['secret_key'])
})
