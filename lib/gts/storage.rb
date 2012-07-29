module Gts
  class Storage

    # append new item to the end of the list
    def append(value)
      
    end

    # get all the elements in the list and empty it
    def dump
      
    end

    # get the count of the elements in the list
    def size
      
    end

  end
end

Dir[File.dirname(__FILE__) +"/storages/*.rb"].each {|file| require file }
