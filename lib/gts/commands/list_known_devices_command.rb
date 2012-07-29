require "gts/command"

module Gts

  class ListKnownDevicesCommand < Command

    Gts::Command.register :list_known_devices, self, "Lists all IMEIs together with the type of device"
    Gts::Command.register :ld, self, "Alias for list_known_devices"

    def execute
      Gts.server.list_known_devices
    end

  end

end
