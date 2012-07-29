require "gts/command_parser"

module Gts

  class Command

    class CommandError < StandardError; end
    class UnknownCommand < CommandError; end

    @@known_commands = {}
    attr_reader :args

    def self.register(name, handler)
      @@known_commands[name] = handler
    end

    def self.execute(command_str)
      parser = Gts::CommandParser.new
      command_name, @args = *parser.parse(command_str)
      command_handler(command_name.to_sym).execute
    end

    private

    def self.command_handler(command_name)
      @handler = @@known_commands[command_name]
      raise UnknownCommand if !@handler
      @handler.new
    end

  end

end

Dir[File.dirname(__FILE__) +"/commands/*.rb"].each {|file| require file }
