class RenderJob < ApplicationJob
  queue_as Rails.application.config.resque_queue

  def perform asset_output_id
    asset_output = AssetOutput.find(asset_output_id)
    asset        = asset_output.asset
    # Retrieve the original asset
    original_filename       = "#{asset.id}_#{asset.image_fingerprint}_original#{asset.file_extension}"
    file                    = PHOTOGRAPHIC_MEMORY_CLIENT.get original_filename
    asset_output.image_data = PHOTOGRAPHIC_MEMORY_CLIENT.put({
      file: file, 
      id: asset.id,
      convert_options: asset_output.convert_options, 
      style_name: asset_output.output.code, 
      content_type: asset_output.content_type 
    })
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
end

