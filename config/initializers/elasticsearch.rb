# ES_CLIENT = Elasticsearch::Client.new(
#   hosts:              Rails.application.secrets.elasticsearch_host,
#   retry_on_failure:   3,
#   reload_connections: true,
# )

# ES_PREFIX = Rails.application.secrets.elasticsearch_prefix

# Elasticsearch::Model.client = ES_CLIENT

# Elasticsearch::Model::Response::Response.__send__ :include, Elasticsearch::Model::Response::Pagination::Kaminari