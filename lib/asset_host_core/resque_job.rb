module AssetHostCore
  class ResqueJob
    @queue = nil

    def self.perform(instance_klass, instance_id, attachment_name, style_args)
      instance = instance_klass.constantize.find(instance_id)
      
      if style_args
        style_args.collect! { |s| s.to_sym }
      end
      
      instance.send(attachment_name).reprocess!(*style_args)
    end
  end
end
