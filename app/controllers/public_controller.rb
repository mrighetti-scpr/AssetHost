class PublicController < ApplicationController
  protect_from_forgery with: :exception

  def home
    render text: "", status: :ok, layout: false
  end

  #----------

  # Given a fingerprint, id and style, determine whether the size has been cut.
  # If so, redirect to the image file. If not, fire off a render process for
  # the style.
  def image
    # if we have a cache key with aprint and style, assume we're good
    # to just return that value
    if img = Rails.cache.read("img:#{params[:id]}:#{params[:aprint]}:#{params[:style]}")
      _send_file(img) and return
    end

    asset = Asset.find_by_id(params[:id])

    if !asset
      render_not_found and return
    end

    asset.request = request

    # Special case for "original"
    # This isn't a "style", just someone has requested
    # the raw image file.
    if params[:aprint] == "original"
      _send_file(asset.file_key) and return
    end

    # valid style?
    output = Output.find_by_code(params[:style])

    if !output
      render_not_found and return
    end

    # do the fingerprints match? If not, redirect them to the correct URL
    if asset.image_fingerprint && params[:aprint] != asset.image_fingerprint
      redirect_to image_path(
        :aprint   => asset.image_fingerprint,
        :id       => asset.id,
        :style    => params[:style]
      ), status: :moved_permanently and return
    end

    # do we have a rendered output for this style?
    # if not then create a new one.
    retries = 0
    begin
      asset_output = asset.outputs.where(output_id: output.id, image_fingerprint: asset.image_fingerprint).first_or_create
    rescue ActiveRecord::RecordNotUnique => ex
      if ex.message =~ /Duplicate entry/
        retries += 1
        raise ex if retries > 3  # max 3 retries 
        sleep 5
        retry
      else
        raise ex
      end
    end

    # if a new asset_output gets created, it should automatically
    # fire off a new render job that will then give it a fingerprint

    5.times do
      asset_output.reload
      if asset_output.fingerprint.present?
        path = asset.file_key(asset_output)
        sent_file = _send_file(path)
        if sent_file
          Rails.cache.write("img:#{asset.id}:#{asset.image_fingerprint}:#{output.code}",
                            path,
                            expires_in: 30.minutes)
          return
        else
          RenderJob.enqueue_uniq(asset_output.id)
          sleep 0.5
        end
      else
        # nope... sleep!
        RenderJob.enqueue_uniq(asset_output.id)
        sleep 0.5
      end
    end

    # crap.  totally failed.
    redirect_to asset.image_url(output.code) and return
  end


  private

  def _send_file(filename)
    downloader = PhotographicMemory.new({
      environment:          Rails.env,
      s3_bucket:            Rails.application.secrets.s3['bucket'],
      s3_region:            Rails.application.secrets.s3['region'],
      s3_endpoint:          Rails.application.secrets.s3['endpoint'],
      s3_access_key_id:     Rails.application.secrets.s3['access_key_id'],
      s3_secret_access_key: Rails.application.secrets.s3['secret_access_key']
    })
    begin
      file       = downloader.get(filename)
    rescue Aws::S3::Errors::NoSuchKey
    end

    if file
      send_data file.read, type: AssetHostUtils.guess_content_type(filename), disposition: 'inline'
    end
  end

end

