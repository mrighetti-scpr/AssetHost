class RenderJob < ApplicationJob
  queue_as Rails.application.config.resque_queue

  def perform asset_output_id
    asset_output = AssetOutput.find(asset_output_id)
    asset        = asset_output.asset
    client       = PhotographicMemory.new
    file         = client.get "#{asset.id}_#{asset.image_fingerprint}_original.jpg"
    asset_output.image_data = client.put file: file, id: asset.id, convert_options: asset_output.convert_options, style_name: asset_output.output.code, content_type: asset.try(:image_content_type)
    asset_output.save
  end
end

