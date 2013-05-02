ENV["RAILS_ENV"] ||= 'test'
require 'bundler/setup'

require 'combustion'
Combustion.initialize! :active_record, :action_controller, :action_view


require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end
