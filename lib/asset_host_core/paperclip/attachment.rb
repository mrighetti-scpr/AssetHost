module Paperclip
  class Attachment
    # Overwrite styles loader to allow caching despite dynamic loading
    def styles
      styling_option = proc { Output.all_sizes }

      if !@normalized_styles
        @normalized_styles = ActiveSupport::OrderedHash.new
        styling_option.call(self).each do |name, args|
          @normalized_styles[name] = Paperclip::Style.new(name, args.dup, self)
        end
      end
      @normalized_styles
    end

    def delete_path(path)
      @queued_for_delete = [ path ]
      self.flush_deletes
    end

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
          width  = ((self.instance_read("width") || 0) * factor).round
          return width < self.instance_read("width") ? width : self.instance_read("width")
        end
      end

      nil
    end

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

    def _compute_style_ratio(style)
      w = self.instance_read("width")
      h = self.instance_read("height")

      return 0 if !w || !h

      g = Paperclip::Geometry.parse(style.processor_options[:size])
      ratio = Paperclip::Geometry.new( g.width/w, g.height/h )

      # we need to compute off the smaller number
      factor = (ratio.width > ratio.height) ? ratio.height : ratio.width
    end

    def tags(args = {})
      tags = {}

      self.styles.each do |style,v|
        tags[style] = self.tag(style,args)
      end

      tags
    end

    def tag(style = default_style, args={})
      s = self.styles[style.to_sym]
      return nil if !s

      if (s.instance_variable_get :@other_args)[:rich] && self.instance.native
        args = args.merge(self.instance.native.attrs)
      end

      htmlargs = args.collect { |k,v| %Q!#{k}="#{v}"! }.join(" ")

      %Q(<img src="#{self.instance.image_url(style)}" width="#{self.width(style)}" height="#{self.height(style)}" alt="#{self.instance.title.to_s.gsub('"', ERB::Util::HTML_ESCAPE['"'])}" #{htmlargs}/>).html_safe
    end
  
  end
end

