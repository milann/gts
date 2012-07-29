# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "gts"

CORRECT_LINE = "1207272321,0907532880,GPRMC,222120.000,A,4809.5363,N,01707.7398,E,4.65,185.29,270712,,,A*6C,F,imei:359585017718724,104X?"
INCORRECT_LINE = "blah"

describe Gts::TK102Handler  do

  let(:handler) { Gts::TK102Handler.new }

  it "parses GPS data when data is correct" do
    handler.parse(CORRECT_LINE).should be_a Hash
  end

  it "throws an exception when GPS data is incorrect" do
    expect {
      handler.parse(INCORRECT_LINE)
    }.to raise_exception(Gts::TK102Handler::CantParseGPSData)
  end
  
end
