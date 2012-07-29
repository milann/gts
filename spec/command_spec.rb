# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "gts"

describe Gts::Command  do

  class SomeCommand < Gts::Command
  end

  it "allows to register new commands" do
    expect {
      SomeCommand.register :some, SomeCommand
    }.not_to raise_exception
  end

end
