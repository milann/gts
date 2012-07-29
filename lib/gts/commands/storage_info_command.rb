require "gts/command"

module Gts

  class StorageInfoCommand < Command

    Gts::Command.register :storage_info, self
    Gts::Command.register :si, self

    def execute
      Gts.storage.info
    end

  end

end
