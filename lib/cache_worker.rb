class CacheWorker
  attr_accessor :verbose

  #----------

  def initialize(options={})
    self.verbose = options[:verbose]

    # grab redis information from cache
    @pubsub_options  = Rails.application.config.assethost.redis_pubsub

    @pubsub         = Redis.new(@pubsub_options[:server])

    @scprv4_redis   = Redis.new(Rails.application.config.cache_dependents['scprv4'])
    @av_redis       = Redis.new(Rails.application.config.cache_dependents['audiovision'])

    self.log("Listening on #{@pubsub.id}")
    self.log("Connected to SCPRv4 cache at #{@scprv4_redis.id}")
    self.log("Connected to AudioVision cache at #{@av_redis.id}")
  end

  #----------

  def work
    # subscribe...
    @pubsub.subscribe(@pubsub_options[:key]) do |on|
      on.subscribe do |channel,subscriptions|
        self.log("Subscribed to #{channel}")
      end

      on.message do |channel,message|
        # message will be a simple JSON object with an :action and an :id
        # in either case we'll just delete the cache for now
        obj = JSON.parse(message)
        key = "asset/asset-#{obj['id']}"
        self.log("Expiring #{key}")

        @scprv4_redis.del(key)
        @av_redis.del(key)
      end

      on.unsubscribe do |channel,subscriptions|
        self.log("Unsubscribed from #{channel}")
      end
    end
  end

  #----------

  def pid
    Process.pid
  end

  #----------

  def log(msg)
    if verbose
      $stderr.puts "***[#{Time.now}] #{msg}"
    end
  end
end