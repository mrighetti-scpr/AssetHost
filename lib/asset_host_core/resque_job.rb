module AssetHostCore
  class ResqueJob
    @queue = nil

    def self.perform(instance_klass, instance_id, attachment_name, style_args)
      instance = instance_klass.constantize.find(instance_id)
      
      styles = style_args.map(&:to_sym) if style_args
      
      instance.send(attachment_name).reprocess!(*styles)
    end
  end
end
