require "gts/command"

module Gts

  class UptimeCommand < Command

    Gts::Command.register :uptime, self

    def execute
      Gts.server.uptime 
    end

  end

end
