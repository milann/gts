module Gts
  
  class CommandParser

    attr_reader :command, :args

    def iniialize
      @command = nil
      @args = [] 
    end

    # zatial vieme parsovat iba primitivne veci
    # status 
    # last_data
    # known_imeis
    # uptime
    def parse(str)
      command, *@args = str.split(/\s+/)
      @command = command.to_sym
      [@command, @args]
    end

  end

end
