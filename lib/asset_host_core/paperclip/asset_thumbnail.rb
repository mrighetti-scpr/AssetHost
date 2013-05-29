module Paperclip
  class AssetThumbnail < Paperclip::Thumbnail
    attr_accessor :prerender, :output, :asset

    def initialize(file, options={}, attachment=nil)
      @prerender    = options[:prerender]
      @size         = options[:size]
      @output       = options[:output]
      @asset        = attachment ? attachment.instance : nil
      @attachment   = attachment

      super

      gravity = @asset.image_gravity? ? @asset.image_gravity : "Center"

      @convert_options = [
        "-gravity #{gravity}",
        "-strip",
        "-quality 95",
        @convert_options
      ].flatten.compact
    end

    # Perform processing, if prerender == true or we've had to render 
    # this output before. Afterward, update our AssetOutput entry 
    def make
      # do we have an AssetOutput already?
      ao = @asset.outputs.where(output_id: @output).first

      dst = nil

      if @prerender || ao
        if !ao 
          # register empty AssetObject to denote processing
          ao = @asset.outputs.create(
            :output_id            => @output,
            :image_fingerprint    => @asset.image_fingerprint
          )
        end

        if @size =~ /(\d+)?x?(\d+)?([\#>])?$/ && $~[3] == "#"
          # crop...  scale using dimensions as minimums, then crop to dimensions
          scale = "-scale #{$~[1]}x#{$~[2]}^"
          crop  = "-crop #{$~[1]}x#{$~[2]}+0+0"

          @convert_options = [
            @convert_options.shift,
            scale,
            crop,
            @convert_options
          ].flatten
        else
          # don't crop
          scale = "-scale '#{$~[1]}x#{$~[2]}#{$~[3]}'"
          @convert_options = [scale, @convert_options].flatten
        end

        # call thumbnail generator
        dst = super

        # need to get dimensions
        width = height = nil

        begin
          geo     = Geometry.from_file(dst.path)
          width   = geo.width.to_i
          height  = geo.height.to_i
        rescue NotIdentifiedByImageMagickError => e
          # hmmm... do nothing?
        end

        # get fingerprint
        print = Digest::MD5.hexdigest(dst.read)
        dst.rewind if dst.respond_to?(:rewind)

        ao.attributes = { 
          :fingerprint          => print,
          :width                => width,
          :height               => height,
          :image_fingerprint    => @asset.image_fingerprint
        }
        
        ao.save

        # just to be safe...
        @asset.outputs(true)
      end

      dst
    end
  end
end
