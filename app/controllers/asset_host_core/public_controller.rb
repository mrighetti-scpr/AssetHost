module AssetHostCore
  class PublicController < AssetHostCore::ApplicationController
    
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

      # Special case for "original"
      # This isn't a "style", just someone has requested 
      # the raw image file.
      if params[:aprint] == "original"
        _send_file(asset.image.path) and return
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
      asset_outputs = asset.outputs.where(output_id: output.id)
    
      if asset_outputs.present?
        if asset_outputs.first.fingerprint.present?
          # Yes, return the image
          # the file may still not have been written yet. loop a try to return it
        
          5.times do 
            if asset.image.exists? output.code_sym
              # got it.  cache and return
              
              path = asset.image.path(output.code)
              Rails.cache.write("img:#{asset.id}:#{asset.image_fingerprint}:#{output.code}",path)
              
              _send_file(path) and return
            end
          
            # nope... sleep!
            sleep 0.5
          end
        
          # crap.  totally failed.
          redirect_to asset.image.url(output.code) and return
        else

          # we're in the middle of rendering
          # sleep for 500ms to try and let the render complete, then try again
          sleep 0.5
          redirect_to asset.image.url(output.code) and return
        end
      
      else
        # No, fire a render for the style
      
        # create an AssetOutput with no fingerprint
        asset.outputs.create(output_id: output.id, image_fingerprint: asset.image_fingerprint)
      
        # and fire the queue  
        asset.image.enqueue_styles(output.code)
      
        # now, sleep for 500ms to try and let the render complete, then try again
        sleep 0.5
        redirect_to asset.image.url(output.code) and return
      end
    end


    private

    def _send_file(file)
      send_file file, type: "image/jpeg", disposition: 'inline'
    end
  end
end
