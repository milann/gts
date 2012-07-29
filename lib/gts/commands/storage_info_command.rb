require "gts/command"

module Gts

  class StorageInfoCommand < Command

    Gts::Command.register :storage_info, self, "Returns information about storage engine"
    Gts::Command.register :si, self, "Alias for storage_info"

    def execute
      Gts.storage.info
    end

  end

end
