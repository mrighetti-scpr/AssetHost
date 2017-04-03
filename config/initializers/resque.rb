# Resque.redis = "#{Rails.application.secrets["resque"]}/assethost-#{Rails.env}"

Resque.redis = "#{Rails.application.secrets["resque"]}/assethost-#{Rails.env}"

# Every time a job is started, make sure the connection
# to MySQL is okay. This avoids the "MySQL server has gone away"
# error.
Resque.after_fork = Proc.new {
  ActiveRecord::Base.clear_active_connections!
}
