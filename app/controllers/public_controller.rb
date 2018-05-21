class PublicController < ActionController::API

  # Given a fingerprint, id and style, determine whether the size has been cut.
  # If so, redirect to the image file. If not, fire off a render process for
  # the style.
  def image
    asset = AssetX.find_by(id: params[:id])

    return head(404) if !asset

    asset.request = request

    # 🚨 See if we can do away with this and
    #    instead rely on the "original" output object.
    # Special case for "original"
    # This isn't a "style", just someone has requested
    # the raw image file.
    if params[:aprint] == "original"
      _send_file(asset.file_key("original")) and return
    end

    # valid style?
    output = OutputX.find_by(name: params[:style])

    return head(404) if !output

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
    rendering = asset.outputs.where(name: output.name)
                                .first_or_create(should_prerender: output.prerender?)
    rendering.render

    # if a new rendering gets created, it should automatically
    # fire off a new render job that will then give it a fingerprint
    5.times do
      asset.reload
      rendering = asset.outputs.find_by(name: output.name)
      if rendering.fingerprint.present?
        path = asset.file_key(rendering.name)
        _send_file(path) and return
      else
        # nope... sleep!
        sleep 0.5
      end
    end

    # crap.  totally failed.
    redirect_to asset.image_url(output.name) and return

  end


  private

  def _send_file(filename)
    file       = PHOTOGRAPHIC_MEMORY_CLIENT.get(filename)
    send_data file.read, type: AssetHostUtils.guess_content_type(filename), disposition: 'inline'
  rescue Aws::S3::Errors::NoSuchKey
    head 404
    # It's possible that a requested image won't be available in S3
    # even though we already have a fingerprint.  Sometimes a URL
    # might also be malformed.  This error doesn't really help us
    # here.
  end

end

