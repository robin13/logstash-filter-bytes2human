# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/bytes2human"

describe LogStash::Filters::Bytes2Human do
   
  describe "To Bytes" do
    # The logstash config.
    config <<-CONFIG
      filter {  bytes2human { convert => { "size" => "bytes" } } }
    CONFIG
  
    describe "should convert from kb" do
      sample( "size" => "10kb" ) do
        expect( subject["size"] ).to eq( 10000 )
      end
    end
    
    describe "should convert from mb" do
      sample( "size" => "10MB" ) do
        expect( subject["size"] ).to eq( 10000000 )
      end
    end
    
    describe "should convert from gb" do
      sample( "size" => "10gb" ) do
        expect( subject["size"] ).to eq( 10000000000 )
      end
    end


    describe "should convert from tb" do
      sample( "size" => "10.4tb" ) do
        expect( subject["size"] ).to eq( 10400000000000 )
      end
    end


    describe "should convert from mib" do
      sample( "size" => "10.4mib" ) do
        expect( subject["size"] ).to eq( 10905190 )
      end
    end

    describe "should round to nearest byte - partial bytes don't exist" do
      sample( "size" => "1.54321kb" ) do
        expect( subject["size"] ).to eq( 1543 )
      end
    end
    
    describe "should deal undefined" do
      sample( "size_not" => 123 ) do
        expect( subject["size"] ).to be_nil
      end
    end
  end
  
  describe "To Human" do
    # The logstash config.
    config <<-CONFIG
      filter {  bytes2human { convert => { "size" => "human" } } }
    CONFIG
  
    describe "should convert integer to KB" do
      sample( "size" => 123456 ) do
        expect( subject["size"] ).to eq( "123.46 kB" )
      end
    end
    
    describe "should convert string to MB" do
      sample( "size" => "987654321" ) do
        expect( subject["size"] ).to eq( "987.65 MB" )
      end
    end
    
    describe "should deal with a zero value" do
      sample( "size" => 0 ) do
        expect( subject["size"] ).to eq( "0.00 B" )
      end
    end
    
    describe "should deal undefined" do
      sample( "size_not" => 123 ) do
        expect( subject["size"] ).to be_nil
      end
    end
  end
end
