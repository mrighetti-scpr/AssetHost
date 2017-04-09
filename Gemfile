source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.2'
gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.5'
gem 'jwt', '~> 0.1.4'
gem 'responders'

gem "paperclip", "5.0.0"
gem "elasticsearch-model", "~> 0.1.9"
gem "searchkick"
gem "cocaine", "0.5.8"
gem "resque", "~> 1.27.2"
gem 'sinatra', github: 'sinatra/sinatra', branch: 'master', require: false
# ^^ we need this for the resque interface to work, sadly
gem "mini_exiftool", "~> 2.8.0"
gem "faraday", "~> 0.8.7"
gem "faraday_middleware", "~> 0.9.0"
gem "google-api-client", "~> 0.6.3"
gem "brightcove-api", "~> 1.0.12"

gem "bootstrap-sass", "~> 2.3.1"
gem "eco", '~> 1.0.0'
gem "simple_form", "~> 3.4.0"
gem "kaminari", "~> 0.14.1"

gem "aws-sdk", "~> 2"


# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'spring'
end

group :test do 
  gem "capybara"
  gem "combustion"
  gem "factory_girl"
  gem "fakeweb"
  gem "launchy"
  gem "rspec", ">= 3.6.0.beta2"
  gem "rspec-rails", ">= 3.6.0.beta2"
  gem "rails-controller-testing"
  gem "rspec-its"
end

