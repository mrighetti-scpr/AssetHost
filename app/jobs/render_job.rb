class RenderJob < ActiveJob::Base
  queue_as Rails.application.config.resque_queue

  def perform asset_id, output_name, file=nil
    output = Output.find_by(name: output_name)
    asset  = Asset.find(asset_id)
    return if !asset || !output
    # Retrieve the original asset
    unless file
      original_filename = asset.file_key("original")
      file              = PHOTOGRAPHIC_MEMORY_CLIENT.get original_filename
    end
    content_type = output.content_type || asset.image_content_type
    image_data   = PHOTOGRAPHIC_MEMORY_CLIENT.put({
      file:            file,
      id:              asset.id,
      convert_options: output.convert_arguments,
      style_name:      output.name, 
      content_type:    content_type
    })
    rendering    = asset.outputs.find_or_create_by(name: output.name)
    rendering.update({
      fingerprint:  output.name == "original" ? "original" : image_data[:fingerprint],
      width:        image_data[:metadata].ImageWidth,
      height:       image_data[:metadata].ImageHeight,
      content_type: content_type
    })
    image_data
  rescue Aws::S3::Errors::NoSuchKey => e
    puts e.message
  end
end

