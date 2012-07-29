require "gts/command"

module Gts

  class HelpCommand < Command

    Gts::Command.register :help, self, "Returns this list"

    def execute
      Gts::Command.known_commands_descriptions.map { |k, v|
        "#{k.to_s.ljust(30)} - #{v}" 
      }.join("\n")
    end

  end

end
