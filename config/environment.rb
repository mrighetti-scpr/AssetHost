# Assigns a Docker host if using Docker -- defaults to localhost
DOCKER_HOST = ENV['DOCKER_HOST'] ? URI(ENV['DOCKER_HOST']).host : "localhost"

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
