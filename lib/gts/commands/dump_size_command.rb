require "gts/command"

module Gts

  class DumpSizeCommand < Command

    Gts::Command.register :dump_size, self, "Returns number of records saved in the storage"
    Gts::Command.register :ds, self, "Alias for dump_size"

    def execute
      Gts.storage.size.to_s
    end

  end

end
