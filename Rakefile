#!/usr/bin/env rake
RAKED = true

require 'bundler/setup'
require 'resque/tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

Bundler::GemHelper.install_tasks
