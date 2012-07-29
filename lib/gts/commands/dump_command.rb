require "gts/command"
require "json"

module Gts

  class DumpCommand < Command

    Gts::Command.register :dump, self

    def execute
      Gts.storage.dump.map{|l| JSON.parse(l) }.to_json
    end

  end

end
