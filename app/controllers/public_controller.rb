class PublicController < ActionController::API

  # Given a fingerprint, id and style, determine whether the size has been cut.
  # If so, redirect to the image file. If not, fire off a render process for
  # the style.
  def image
    
    asset = Asset.find_by(id: params[:id])
  
    return head(404) if !asset

    if request.headers['If-None-Match']
      a_id, a_print, r_print = request.headers['If-None-Match'].split(":")
      rendering = asset.renderings.where(fingerprint: r_print)
      head(304) and return if rendering && a_id == asset.id
    end

    asset.request = request

    # valid style?
    output = Output.find_by(name: params[:style])

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
    rendering = asset.renderings.where(name: output.name)
                             .first_or_create(should_prerender: output.prerender?)
    rendering.render

    # if a new rendering gets created, it should automatically
    # fire off a new render job that will then give it a fingerprint
    5.times do
      asset.reload
      rendering = asset.renderings.find_by(name: output.name)
      if rendering.fingerprint.present?
        file_key = asset.file_key(rendering.name)
        response.headers['Cache-Control'] = "public, max-age=31536000"
        response.headers['ETag']          = "#{asset.id}:#{asset.image_fingerprint}:#{rendering.fingerprint}"
        _send_file(file_key, rendering.content_type) and return
      else
        # nope... sleep!
        sleep 0.5
      end
    end

    # crap.  totally failed.
    redirect_to asset.image_url(output.name) and return

  end


  private

  def _send_file file_key, content_type
    file = AssetHostCore::Renderer.get(file_key)
    send_data file.read, type: content_type, disposition: 'inline'
  rescue Aws::S3::Errors::NoSuchKey => e
    head 404
    # It's possible that a requested image won't be available in S3
    # even though we already have a fingerprint.  Sometimes a URL
    # might also be malformed.  This error doesn't really help us
    # here.
  end

end

