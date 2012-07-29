require "logger"

module Gts

  def self.register_handler(klass)
    @@registered_handlers ||= {}
    klass.devices.each do |d|
      @@registered_handlers[d] = klass
    end
  end
  
  def self.registered_handlers
    @@registered_handlers
  end

  def self.set_log_level(level=:info)
    case level
    when :debug
      @@log_level = Logger::DEBUG
    else 
      @@log_level = Logger::INFO
    end
  end

  def self.log_level
    begin
      @@log_level
    rescue
      set_log_level
      @@log_level
    end
  end

  def self.logger
    begin 
      @@logger
    rescue
      @@logger = Logger.new(STDOUT)
      @@logger.datetime_format = "%d.%m.%Y %H:%M:%S"
      @@logger.formatter = proc do |severity, datetime, progname, msg|
        "#{datetime} #{severity}: #{msg}\n"
      end
      @@logger.level = log_level
      @@logger
    end
  end

  def self.server=(server_instance)
    @@server = server_instance
  end

  def self.server
    @@server
  end

  def self.storage=(storage)
    @@storage = storage
  end

  def self.storage
    @@storage
  end

end

require "gts/version"
require "gts/utils/phone_system"
require "gts/abstract_gps_tracker_handler"
require "gts/handlers/tk102_handler"
require "gts/command"
require "gts/storage"
require "gts/server"
