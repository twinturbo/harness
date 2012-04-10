require "harness/version"

require 'thread'

require 'securerandom'

require 'redis'
require 'redis/namespace'

require 'active_support/notifications'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash/keys'

module Harness
  class LoggingError < RuntimeError ; end

  class Config
    attr_reader :adapter, :queue

    def adapter=(val)
      if val.is_a? Symbol
        @adapter = "Harness::#{val.to_s.classify}Adapter".constantize
      else
        @adapter = val
      end
    end

    def queue=(val)
      if val.is_a? Symbol
        @queue= "Harness::#{val.to_s.classify}Queue".constantize
      else
        @queue= val
      end
    end

    def method_missing(name, *args, &block)
      begin
        "Harness::#{name.to_s.classify}Adapter".constantize.config
      rescue NameError
        super
      end
    end
  end

  def self.config
    @config ||= Config.new
  end

  def self.log(measurement)
    config.queue.push measurement
  end

  def self.logger
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.redis=(redis)
    @redis = redis
  end

  def self.redis
    @redis
  end

  def self.reset_counters!
    redis.smembers('counters').each do |counter|
      redis.set counter, -1
    end
  end
end

require 'harness/measurement'
require 'harness/counter'
require 'harness/gauge'

require 'harness/instrumentation'

require 'harness/job'

require 'harness/queues/syncronous_queue'

require 'harness/adapters/librato_adapter'
require 'harness/adapters/memory_adapter'
require 'harness/adapters/null_adapter'

require 'harness/integration/action_controller'
require 'harness/integration/action_view'
require 'harness/integration/action_mailer'
require 'harness/integration/active_support'

require 'harness/railtie' if defined?(Rails)

require 'logger'

Harness.logger = Logger.new $stdout
