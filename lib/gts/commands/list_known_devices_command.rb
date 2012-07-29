require "gts/command"

module Gts

  class ListKnownDevicesCommand < Command

    Gts::Command.register :list_known_devices, self
    Gts::Command.register :ld, self

    def execute
      Gts.server.list_known_devices
    end

  end

end
