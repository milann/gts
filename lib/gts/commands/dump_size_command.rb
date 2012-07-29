require "gts/command"

module Gts

  class DumpSizeCommand < Command

    Gts::Command.register :dump_size, self
    Gts::Command.register :ds, self

    def execute
      Gts.storage.size
    end

  end

end
