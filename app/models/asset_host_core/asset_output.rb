module AssetHostCore
  class AssetOutput < ActiveRecord::Base
    belongs_to :asset
    belongs_to :output
    
    before_save :delete_cache_and_img, if: -> { self.fingerprint_changed? || self.image_fingerprint_changed? }
    before_destroy :delete_cache_and_img_and_fingerprint
    
    after_commit :cache_img_path, if: -> { self.image_fingerprint.present? && self.fingerprint.present? }

    scope :rendered, -> { where("fingerprint != ''") }
    
    
    #----------
    
    protected
    
    # on save, check whether we should be creating or deleting caches
    def delete_cache_and_img
      # -- out with the old -- #
      
      finger    = self.fingerprint_changed? ? self.fingerprint_was : self.fingerprint
      imgfinger = self.image_fingerprint_changed? ? self.image_fingerprint_was : self.image_fingerprint
            
      if finger && imgfinger
        # -- delete our old cache -- #
        resp = Rails.cache.delete("img:"+[self.asset.id,imgfinger,self.output.code].join(":"))
        
        # -- delete our AssetOutput -- #
        path = self.asset.image.path(self)
        
        if path
          # this path could have our current values in it. make sure we've 
          # got old fingerprints
          path = path.gsub(self.asset.image_fingerprint,imgfinger).gsub(self.fingerprint,finger)

          self.asset.image.delete_path(path)
        end
      end
      
      true
    end
    
    #----------
    
    # on destroy, we need to do the normal save deletes and also delete our fingerprint
    def delete_cache_and_img_and_fingerprint
      self.delete_cache_and_img
      
      # why do we bother clearing our fingerprint if the AssetOutput itself 
      # is about to get deleted? If we don't, the after_commit handler will 
      # rewrite the same cache we just deleted.
      self.fingerprint = ''
    end
    
    #----------
    
    def cache_img_path
      # -- in with the new -- #
      path = self.asset.image.path(self)
      
      if path && File.exists?(path)
        Rails.cache.write("img:"+[self.asset.id,self.image_fingerprint,self.output.code].join(":"),path)
      end
      
      true
    end
  end
end
