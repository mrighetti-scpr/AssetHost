class RenderJob < ApplicationJob
  queue_as Rails.application.config.resque_queue

  after_perform do |job|
    RenderJob.delete_cache_key(job.arguments.first)
  end

  def self.enqueue_uniq(asset_output_id)
    unless Rails.cache.read(render_job_cache_key(asset_output_id))
      Rails.cache.write(render_job_cache_key(asset_output_id), :expires_in => 3.minutes)
      RenderJob.perform_later(asset_output_id)
    end
  end

  def self.delete_cache_key(asset_output_id)
    Rails.cache.delete(render_job_cache_key(asset_output_id))
  end


  def perform asset_output_id
    asset_output = AssetOutput.find(asset_output_id)
    asset        = asset_output.asset
    client       = PhotographicMemory.new({
                                            environment:          Rails.env,
                                            s3_bucket:            Rails.application.secrets.s3['bucket'],
                                            s3_region:            Rails.application.secrets.s3['region'],
                                            s3_endpoint:          Rails.application.secrets.s3['endpoint'],
                                            s3_access_key_id:     Rails.application.secrets.s3['access_key_id'],
                                            s3_secret_access_key: Rails.application.secrets.s3['secret_access_key']
                                          })
    # Retrieve the original asset
    file         = client.get "#{asset.id}_#{asset.image_fingerprint}_original#{asset.file_extension}"
    asset_output.image_data =
      client.put file: file, id: asset.id,
                 convert_options: asset_output.convert_options,
                 style_name: asset_output.output.code,
                 content_type: asset_output.content_type,
                 key: asset.file_key(asset_output)

      retries = 0

    begin
      asset_output.save
    rescue  ActiveRecord::StatementInvalid => ex
      if ex.message =~ /Deadlock found when trying to get lock/ #ex not e!!
        retries += 1
        raise ex if retries > 3  ## max 3 retries
        sleep 5
        retry
      else
        raise ex
      end
    end
  end

  def self.render_job_cache_key(id)
    "RenderJob_uniq_by_asset_output:#{id}"
  end

end
