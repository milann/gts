require "gts/command"
require "json"

module Gts

  class DumpCommand < Command

    Gts::Command.register :dump, self, "Dumps captured GPS data from tracking devices into json"

    def execute
      dump = Gts.storage.dump
      if dump
        dump.map{|l| JSON.parse(l) }.to_json
      else
        [].to_json
      end
    end

  end

end
