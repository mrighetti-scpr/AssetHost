class AssetOutput < ActiveRecord::Base
  self.table_name = "asset_host_core_asset_outputs"

  belongs_to :asset
  belongs_to :output

  before_save :delete_cache_and_img, if: -> { self.fingerprint_changed? || self.image_fingerprint_changed? }
  before_destroy :delete_cache_and_img_and_fingerprint

  after_commit :cache_img_path, if: -> { self.image_fingerprint.present? && self.fingerprint.present? }

  scope :rendered, -> { where("fingerprint != ''") }

  after_save :render

  #----------

  def convert_options
    # arguments that get passed to imagemagick
    options = [
      "-gravity #{asset.image_gravity || 'center'}",
      "-strip",
      "-quality 95"
    ]

    if self.output.size =~ /(\d+)?x?(\d+)?([\#>])?$/ && $~[3] == "#"
      # crop...  scale using dimensions as minimums, then crop to dimensions
      scale = "-scale #{$~[1]}x#{$~[2]}^"
      crop  = "-crop #{$~[1]}x#{$~[2]}+0+0"

      options = [
        options.shift,
        scale,
        crop,
        options
      ].flatten
    else
      # don't crop
      scale = "-scale '#{$~[1]}x#{$~[2]}#{$~[3]}'"
      options = [scale, options].flatten
    end

    options
  end

  def image_data= data
    self.fingerprint = data[:fingerprint]
    self.width       = data[:metadata].ImageWidth
    self.height      = data[:metadata].ImageHeight
  end

  def prerender?
    output.try(:prerender) || false
  end

  def content_type
    {
      'jpg' => 'image/jpeg',
      'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'png' => 'image/png'
    }[output.extension]
  end

  protected

  def render
    unless fingerprint.present?
      if prerender?
        RenderJob.perform_now(self.id)
      else
        RenderJob.perform_later(self.id)
      end
    end
  end

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

    if self.asset.image.exists?(self)
      Rails.cache.write("img:"+[self.asset.id,self.image_fingerprint,self.output.code].join(":"),self.asset.image.path(self))
    end

    true
  end
end

