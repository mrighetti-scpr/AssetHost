unless Rails.env.test?
  # might be better to spin up a short-lived Redis instance
  Resque.redis = "#{ENV["ASSETHOST_RESQUE_HOST"]}:#{ENV["ASSETHOST_RESQUE_PORT"]}/assethost-#{Rails.env}"
end

# 🚨 Remove this once we're sure this is definitely not going to be needed again.
# # Every time a job is started, make sure the connection
# # to MySQL is okay. This avoids the "MySQL server has gone away"
# # error.
# Resque.after_fork = Proc.new {
#   ActiveRecord::Base.clear_active_connections!
# }
