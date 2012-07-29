require "gts/command"
require "json"

module Gts

  class DumpCommand < Command

    Gts::Command.register :dump, self, "Dumps captured GPS data from tracking devices into json"

    def execute
      Gts.storage.dump.map{|l| JSON.parse(l) }.to_json
    end

  end

end
