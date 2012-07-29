require "redis"

module Gts

  class RedisStorage < Gts::Storage

    attr_reader :redis, :host, :port, :list_id

    def initialize(opts)
      @host = opts[:host] || "0.0.0.0"
      @port = opts[:port] || "6379"
      @list_id = opts[:list_id] || "gts_data"
      @redis = Redis.new(:host => @host, :port => @port)
      begin
        @redis.ping
      rescue Redis::CannotConnectError
        puts "Failed to start. Redis is not running or wrong host/port provided."
        exit
      end
    end

    # append new item to the end of the list
    def append(value)
      redis.rpush list_id, value
    end

    # get all the elements in the list and empty it
    def dump
      current_size = size
      dumped_items = redis.lrange list_id, 0, current_size - 1
      redis.ltrim list_id, current_size, size - 1 
      dumped_items
    end

    # get the count of the elements in the list
    def size
      redis.llen list_id
    end
    
    def info
      redis.info.map{ |k,v| "#{k}: #{v}" }.join("\n")
    end

  end

end
