require "logger"
require "fileutils"

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
      set_logger
      @@logger
    end
  end

  def self.set_logger
    @@logger = Logger.new(log_filename)
    @@logger.datetime_format = "%d.%m.%Y %H:%M:%S"
    @@logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime} #{severity}: #{msg}\n"
    end
    @@logger.level = log_level
  end

  def self.set_log_filename(filename)
    @@log_filename = File.expand_path(filename) 
    FileUtils.touch filename
  end

  def self.log_filename
    @@log_filename
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

  def self.daemonize
    if RUBY_VERSION < "1.9"
      exit if fork
      Process.setsid
      exit if fork
      Dir.chdir "/" 
      STDIN.reopen "/dev/null"
      STDERR.reopen "/dev/null", "a" 
    else
      orig_stdout = STDOUT.clone
      Process.daemon
      STDOUT.reopen orig_stdout
    end 
    puts "Running in background with PID #{Process.pid}"
    STDOUT.reopen "/dev/null", "a"
    set_logger # reopen logger, just to make sure
  end

end

require "gts/version"
require "gts/utils/phone_system"
require "gts/abstract_gps_tracker_handler"
require "gts/handlers/tk102_handler"
require "gts/command"
require "gts/storage"
require "gts/server"
