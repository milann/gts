require "gts/command"

module Gts

  class UptimeCommand < Command

    Gts::Command.register :uptime, self, "Returns number of h/m/s since the server was started"

    def execute
      Gts.server.uptime 
    end

  end

end
