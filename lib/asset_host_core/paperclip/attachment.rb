module Paperclip
  class Attachment
    # Overwrite styles loader to allow caching despite dynamic loading
    def styles
      styling_option = @options[:styles]

      if !@normalized_styles
        @normalized_styles = ActiveSupport::OrderedHash.new
        styling_option.call(self).each do |name, args|
          @normalized_styles[name] = Paperclip::Style.new(name, args.dup, self)
        end
      end
      @normalized_styles
    end


    # overwrite to only delete original when clear() is called.  styles will
    # be deleted by the thumbnailer
    def queue_existing_for_delete #:nodoc:
      return unless file?

      @queued_for_delete = [path(:original)]

      instance_write(:file_name, nil)
      instance_write(:content_type, nil)
      instance_write(:file_size, nil)
      instance_write(:updated_at, nil)
    end


    #----------

    def delete_path(path)
      @queued_for_delete = [ path ]
      self.flush_deletes
    end

    #----------

    def enqueue
      # queue up any outputs that a) already exist or b) are set to prerender
      styles = [
        AssetHostCore::Output.where(prerender: true).map(&:code_sym),
        self.instance.outputs.map { |ao| ao.output.code_sym }
      ].flatten.uniq

      enqueue_styles(*styles)
    end

    def enqueue_styles(*styles)
      Resque.enqueue(
        AssetHostCore::ResqueJob,
        self.instance.class.name,
        self.instance.id,
        self.name,
        styles
      )
    end

    #----------

    def width(style = default_style)
      return nil if !self.instance_read("width")

      if s = self.styles[style]
        # load dimensions
        if ao = self.instance.output_by_style(style)
          return ao.width
        else
          # TODO: Need to add code to guess dimensions if we don't yet have an output
          g = Paperclip::Geometry.parse(s.processor_options[:size])
          if g.modifier == '#'
            if g.square?
              # match w/h from style
              return g.width.to_i
            else
              return g.width.to_i
            end
          end

          factor = self._compute_style_ratio(s)
          width = ((self.instance_read("width") || 0) * factor).round
          return width < self.instance_read("width") ? width : self.instance_read("width")
        end
      end

      nil
    end

    #----------

    def height(style = default_style)
      return nil if !self.instance_read("height")

      if s = self.styles[style]
        # load dimensions
        if ao = self.instance.output_by_style(style)
          return ao.height
        else
          # TODO: Need to add code to guess dimensions if we don't yet have an output
          g = Paperclip::Geometry.parse(s.processor_options[:size])
          if g.modifier == '#'
            # match w/h from style
            return g.height.to_i
          end

          factor = self._compute_style_ratio(s)
          height = ((self.instance_read("height") || 0) * factor).round

          return height < self.instance_read("height") ? height : self.instance_read("height")

        end
      end

      nil
    end

    #----------

    def isPortrait?
      w = self.instance_read("width")
      h = self.instance_read("height")

      h > w
    end

    #----------

    def _compute_style_ratio(style)
      w = self.instance_read("width")
      h = self.instance_read("height")

      return 0 if !w || !h

      g = Paperclip::Geometry.parse(style.processor_options[:size])
      ratio = Paperclip::Geometry.new( g.width/w, g.height/h )

      # we need to compute off the smaller number
      factor = (ratio.width > ratio.height) ? ratio.height : ratio.width
    end

    #----------

    def tags(args = {})
      tags = {}

      self.styles.each do |style,v|
        tags[style] = self.tag(style,args)
      end

      tags
    end

    #----------

    def tag(style = default_style, args={})
      s = self.styles[style.to_sym]
      return nil if !s

      if (s.instance_variable_get :@other_args)[:rich] && self.instance.native
        args = args.merge(self.instance.native.attrs)
      end

      htmlargs = args.collect { |k,v| %Q!#{k}="#{v}"! }.join(" ")

      %Q(<img src="#{self.url(style)}" width="#{self.width(style)}" height="#{self.height(style)}" alt="#{self.instance.title.to_s.gsub('"', ERB::Util::HTML_ESCAPE['"'])}" #{htmlargs}/>).html_safe
    end

    #----------

    def write_exif_data
      return unless @queued_for_write[:original]

      p = ::MiniExiftool.new(@queued_for_write[:original].path,
        :convert_encoding => true)

      # -- determine metadata -- #

      if p.credit =~ /Getty Images/
        # smart import for Getty Images photos
        copyright     = [p.by_line,p.credit].join("/")
        title         = p.headline
        description   = p.description

      elsif p.credit =~ /AP/
        # smart import for AP photos
        copyright     = [p.by_line,p.credit].join("/")
        title         = p.title
        description   = p.description

      else
        copyright     = p.byline || p.credit
        title         = p.title
        description   = p.description
      end

      instance_write(:width, p.image_width)
      instance_write(:height, p.image_height)
      instance_write(:title, title)
      instance_write(:description, description)
      instance_write(:copyright, copyright)
      instance_write(:taken, p.datetime_original)

      true
    end
  end
end
