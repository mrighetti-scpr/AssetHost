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

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.1"
  s.add_dependency "paperclip", "2.7.0"
  s.add_dependency "brightcove-api", "~> 1.0.12"
  s.add_dependency "will_paginate", "3.0.3"
  s.add_dependency "thinking-sphinx", "~> 2.0.14"
  s.add_dependency "resque", "~> 1.23.0"
  s.add_dependency "less-rails-bootstrap"
  s.add_dependency "formtastic-bootstrap"
  s.add_dependency "mini_exiftool"
  

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
