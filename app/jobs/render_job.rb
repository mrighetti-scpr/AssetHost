class RenderJob < ActiveJob::Base
  queue_as Rails.application.config.resque_queue

  def perform asset_id, output_name, file=nil
    if output_name == "original"
      output = Output.find_or_create_by(name: "original")
    else
      output = Output.find_by(name: output_name)
    end
    asset  = Asset.find(asset_id)
    return if !asset || !output
    unless file # Retrieve the original asset
      original_filename = asset.file_key("original")
      file              = AssetHostCore::Renderer.get original_filename
    end
    content_type = output.content_type || asset.image_content_type
    image_data   = AssetHostCore::Renderer.put({
      file:            file,
      id:              asset.id,
      convert_options: convert_arguments(asset, output),
      classify:        output_name == "original",
      content_type:    content_type
    })
    rendering    = asset.renderings.find_or_create_by(name: output.name)
    rendering.update({
      file_key:     image_data[:filename],
      fingerprint:  image_data[:fingerprint],
      width:        image_data[:metadata].ImageWidth,
      height:       image_data[:metadata].ImageHeight,
      content_type: content_type
    })
    image_data
  rescue Aws::S3::Errors::NoSuchKey => e
    puts e.message
  end

  private

  ##
  # Builds arguments for Imagemagick `convert`
  ##
  def convert_arguments asset, output
    args = []
    return args if output.name == "original"
    render_options = output.render_options || []
    ## 🚨 Find a way to make it so that the asset's gravity doesn't always
    ## override the gravity set in the output (if there is one)
    if asset.image_gravity
      render_options.unshift({
        name: "gravity",
        properties: [
          {
            "name"  => "value",
            "value" => asset.image_gravity
          }
        ]
      })
    end
    render_options.each do |o|
      operation  = OpenStruct.new(o)
      properties = operation.properties.is_a?(Hash) ? operation.properties : (operation.properties || []).inject({}){|result, p| result[p["name"]] = p["value"]; result; }
      properties = OpenStruct.new(properties)
      if operation.name == "gravity"
        args << "-gravity #{properties.value}"
      end
      if operation.name == "scale"
        args << "-scale #{properties.width}x#{properties.height}^"
      end
      if operation.name == "crop"
        args << "-crop #{properties.width}x#{properties.height}+#{properties.offsetX || 0}+#{properties.offsetY || 0}"
      end
      if operation.name == "quality"
        args << "-quality #{properties.value}"
      end
    end
    # args.push("-auto-orient")
    args.push("-quality 95") ## 🚨 Find a better place to put this!
    args.join(" ")
  end
end

