require 'mini_exiftool'

module AssetHostCore
  module ModelMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def treat_as_image_asset(name)
        include InstanceMethodsOnActivation
        
        attachment_definitions[name][:delayed] = true

        define_method "write_exif_data_for_#{name}" do
          if self.send("#{name}").dirty?
            # need to extract dimensions from the attachment
            self.attachment_for(name).write_exif_data
          end
        end

        define_method "enqueue_delayed_processing_for_#{name}" do 
          # we render on two things: image fingerprint changed, or image gravity changed
          if self.previous_changes.include?("image_fingerprint") || self.previous_changes.include?("image_gravity")
            self.attachment_for(name).enqueue
          end
        end

        # register our event handler
        before_save :"write_exif_data_for_#{name}"
        
        if respond_to?(:after_commit)
          after_commit  :"enqueue_delayed_processing_for_#{name}"
        else
          after_save  :"enqueue_delayed_processing_for_#{name}"
        end

        # -- Style fingerprint interpolation -- #
        
        ::Paperclip.interpolates "sprint" do |attachment, style_name|
          if style_name == :original
            'original' 
          elsif ao = attachment.instance.output_by_style(style_name)
            ao.fingerprint
          else
            nil
          end
        end
      end


      module InstanceMethodsOnActivation
        # borrowed from delayed_paperclip... combines with [:delayed] above to turn off the inline processing
        def attachment_for(name)
          @_paperclip_attachments ||= {}
          @_paperclip_attachments[name] ||= ::Paperclip::Attachment.new(name, self, self.class.attachment_definitions[name]).tap do |a|
            a.post_processing = false if self.class.attachment_definitions[name][:delayed]
          end
        end
      end
    end # ClassMethods
  end # Paperclip
end # AssetHostCore
