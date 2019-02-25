class CopyJob < ApplicationJob
  queue_as :migrate_queue

  def perform asset_id
    asset = Asset.find_by_id asset_id
    return unless asset

    new_s3 = Aws::S3::Client.new(
      {
        region:           Rails.application.secrets.s3['region'],
        endpoint:         Rails.application.secrets.s3['endpoint'],
        force_path_style: true,
        credentials: Aws::Credentials.new(
          Rails.application.secrets.s3['access_key_id'],
          Rails.application.secrets.s3['secret_access_key']
        ),
        stub_responses:    false,
        signature_version: "s3"
      }
    )

    old_s3 = Aws::S3::Client.new(
      {
        region:           Rails.application.secrets.s3['old_region'],
        endpoint:         Rails.application.secrets.s3['old_endpoint'],
        force_path_style: true,
        credentials: Aws::Credentials.new(
          Rails.application.secrets.s3['old_access_key_id'],
          Rails.application.secrets.s3['old_secret_access_key']
        ),
        stub_responses:    false,
        signature_version: "s3"
      }
    )

    original =
    begin
      find_in_old_s3(old_s3, "#{asset.id}_#{asset.image_fingerprint}_original#{asset.file_extension}")
    rescue Aws::S3::Errors::NoSuchKey
      begin
        # find a 'full' cut
        full_output = AssetOutput.where(asset_id: asset_id, output_id: 5).first
        begin
          find_in_old_s3(old_s3, asset.file_key(full_output))
        rescue Aws::S3::Errors::NoSuchKey
          false
        end
      end
    end

    if original
      new_s3.put_object({
                          bucket: Rails.application.secrets.s3['bucket'],
                          key: "#{asset.id}_#{asset.image_fingerprint}_original#{asset.file_extension}",
                          body: original.body,
                          content_type: original.content_type
                        })
    end
  end

  def find_in_old_s3(old_s3, key)
    old_s3.get_object(
      bucket: Rails.application.secrets.s3['old_bucket'],
      key: key
    )
  end
end
