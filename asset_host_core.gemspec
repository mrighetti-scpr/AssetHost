$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "asset_host_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "asset_host_core"
  s.version     = AssetHostCore::VERSION
  s.authors     = ["Eric Richardson"]
  s.email       = ["erichardson@scpr.org"]
  s.homepage    = "http://github.com/SCPR/AssetHost"
  s.summary     = "One-stop-shop for media asset management, designed for a newsroom environment."
  s.description = "One-stop-shop for media asset management, designed for a newsroom environment."

  s.files = Dir["{app,config,lib,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir["spec/**/*"]


  s.add_dependency "rails", "~> 3.2.1"
  s.add_dependency "paperclip", "2.7.0"
  s.add_dependency "cocaine", "0.3.2"
  s.add_dependency "thinking-sphinx", "~> 2.0.14"
  s.add_dependency "resque", "~> 1.23.0"
  s.add_dependency "mini_exiftool", "~> 1.6.0"

  s.add_dependency "brightcove-api", "~> 1.0.12"
  s.add_dependency "bootstrap-sass", "~> 2.3.1"
  s.add_dependency 'sass-rails',   '~> 3.2.3'
  s.add_dependency 'coffee-rails', '~> 3.2.1'
  s.add_dependency "eco", '~> 1.0.0'
  s.add_dependency "simple_form", "~> 2.1.0"
  s.add_dependency "kaminari", "~> 0.14.1"

  s.add_development_dependency "rspec-rails", '~> 2.13.0'
  s.add_development_dependency "factory_girl", '~> 4.2.0'
  s.add_development_dependency "fakeweb", '~> 1.3.0'
end
