module Concurrency
  
  extend ActiveSupport::Concern

  module ClassMethods
    def self.first_or_create(attributes = nil, &block)
      super
    rescue ActiveRecord::RecordNotUnique
      # If two workers are trying to create assets, sometimes this happens.
      # Just have the worker retry in that case.
      retry
    end
  end
end

