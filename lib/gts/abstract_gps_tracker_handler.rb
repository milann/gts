module Gts

  class AbstractGPSTrackerHandler

    class CantParseGPSData < StandardError; end

    def self.register!
      Gts.register_handler(self)
    end

    def parse(raw_data)
      raise "Abstract!"
    end

    def devices
      raise "Abstract!"
    end

  end

end
