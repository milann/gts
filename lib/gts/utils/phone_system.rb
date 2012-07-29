require "yaml"

module PhoneSystem
  
  # Exceptions
  class PhoneSystemError < StandardError; end
  class CannotParsePhoneNumberString < PhoneSystemError; end 
  class CannotDetermineCountryCode < CannotParsePhoneNumberString; end   
  class AreaCodeNotValidForGivenCountry < CannotParsePhoneNumberString; end     
  class NumberTooShort < CannotParsePhoneNumberString; end
  class NumberTooLong < CannotParsePhoneNumberString; end  
  
  # For future use, not implemented, yet
  class PhoneNode; end    
  class PhoneCountryNode < PhoneNode; end
  class PhoneAreaNode < PhoneNode; end  

  class Parser
    
    @@phone_codes_file_path = File.join(File.dirname(__FILE__), "phone_codes.yml")
    @@phone_codes = YAML.load(File.read(@@phone_codes_file_path))      

    def parse(pstring, options)
      self.class.parse(pstring, options)
    end
    
    # Return hash, that represents valid international phone number with 
    # country code, area code, number, country, area/operator.
    # 
    # String that do not begin with "+" or "0" are considered invalid.
    # because we want to get absolute phone numbers, not relative, ie.
    # the output will contain country code, area/mobile operator code and number.
    # 
    # Country code is by default set to 421 (Slovakia), so we can leave it
    # when inputting Slovak phone numbers and just start with area code.
    # 
    # Constraints:
    #   - the number that do not start with "+" or "0" are considered invalid 
    #     (since we are not able to determine the area/operator code).
    #   - the country code MUST be separated from the rest of the number by means
    #     of " " or "-".
    # 
	  # Arguments: 
    #   - pstring : string with phone number to parse
    #	options:
    #		- country_code : implicit country phone code, if none found 
	  # 		  in pstring, defaults to 421 (Slovakia)
    #		- strict : if set to true, the pstring is checked against the list of 
	  #		  area/operator codes found in phone_codes.yml. If none of the area/operator 
	  #		  code matches pstring, exception is raised. Use only if you have complete 
	  #         list of the area/operator codes for given country. Defaults to false.
    def self.parse(pstring, options = {})
      
      options = {
        :country_code => 421, # Slovakia
        :strict => false
      }.merge(options)

      text_number = pstring
      # if it starts with "+" or "00" then the country code should be given and we will
      # try to get it.
      if pstring =~ /^(\+|00)/
        cc_match = pstring.match(/^(?:\+|00)(\d*)[ -\(]+/)
        unless  cc_match
        then    raise(CannotParsePhoneNumberString, "The string \"#{text_number}\" does not seem to be valid international phone number."); end
        pstring             = pstring.match(/^[\+0\d]*[ -\(]+(.*)$/)[1] # chop the country code off 
        country_code        = cc_match[1].to_i
      else
        # if the country code is not set, fall to default
        # and chop the first zero, so the area/operator code will be at the first place
        unless  options[:country_code]
        then    raise(CannotDetermineCountryCode, "The string \"#{text_number}\" does not seem to be valid phone number. Cannot determine country code."); end
        pstring       = pstring.sub("0","") # remove the leading zero, to get the area code to the first place
        country_code  = options[:country_code]
      end
      
      # do some cleaning - remove all the remaining characters, that are not digits
      pstring = remove_other_than_digits(pstring)
      
      area_code   = nil
      area_name   = nil
      
      # let's try to identify the country, area/operator and get the correct format for the country
      # if possible
      if @@phone_codes.include? country_code
        country     = @@phone_codes[country_code]["country"]
        area_codes  = @@phone_codes[country_code]["area_codes"]
        pn_format   = Regexp.new(@@phone_codes[country_code]["format"]) if @@phone_codes[country_code].include? "format"
        area_codes.each do |code, name|
          if pstring =~ /^#{code}/
            area_code = code
            area_name = name
            pstring   = pstring.sub(/#{code}/, "") # chop the area code off
            break
          end
        end
        # if not area code found and in strict mode, raise exception
        if    !area_code && options[:strict]
        then  raise(AreaCodeNotValidForGivenCountry, "The string \"#{text_number}\" does not seem to be valid phone number. Area code was not recognized."); end

        # set the number size boundaries if found for given country
        min_size  = @@phone_codes[country_code].include?("min_size") ? @@phone_codes[country_code]["min_size"] : nil
        max_size  = @@phone_codes[country_code].include?("max_size") ? @@phone_codes[country_code]["max_size"] : nil
      end
        
      # if not specific format of numbers for given country set, then 
      # use general format
      pn_format           ||= /^(\+|0)[\d\s\(\)-\/]+$/
      unless text_number  =~  pn_format
      then   raise(CannotParsePhoneNumberString, "The string \"#{text_number}\" does not seem to be valid international phone number."); end
        
      # if no size boundaries set, set them to reasonable defaults
      min_size  ||= 6
      max_size  ||= 15
      # and check the remaining number against them
      if  pstring.size < min_size
      then raise(NumberTooShort, "Cannot parse the string \"#{text_number}\" to phone number. The phone number would be too short."); end
      if  pstring.size > max_size
      then raise(NumberTooLong, "Cannot parse the string \"#{text_number}\" to phone number. The phone number would be too long."); end

      # if we made it here, we have the line number
      number = pstring
      
      out = {
        :text         => text_number,
        :country_code => country_code,
        :country      => country,
        :area_code    => area_code,
        :area_name    => area_name,
        :number       => number
      }
      return out
    rescue PhoneSystemError
      false
    end
    
    private
    
    # my way to remove other chars than digits from a string
    # any better idea?
    def self.remove_other_than_digits(numbers_and_stuff)
      out = [] 
      numbers_and_stuff.each_char{|c| out << c if c=~/\d/ }
      out.join
    end
    
  end
  
  class PhoneNumber
  
    def self.valid?(pstring, options = {})
      !!PhoneSystem::Parser.parse(pstring, options)
    end
    
    def valid?
      PhoneNumber.valid? self.long
    end
  
    def initialize(pstring = nil, options = {})
      @phone_number = {}
      @phone_number = PhoneSystem::Parser.parse(pstring,options) unless (pstring == "" || pstring.nil?)
    end
    
    def country_code
      @phone_number[:country_code]
    end
    
    def country
      @phone_number[:country]
    end  
    
    def area_code
      @phone_number[:area_code]
    end
    
    def area_name
      @phone_number[:area_name]
    end
    
    def area_name
      @phone_number[:area_name]
    end
    
    def number
      @phone_number[:number]
    end
    
    def text
      @phone_number[:text]
    end
    
    def [](attr)
      @phone_number[attr]
    end
  
    def long
      "+#{country_code} #{area_code} #{number}"
    end

    def self.parse_and_format_long(pstring, options={})
      if nr = PhoneSystem::Parser.parse(pstring, options)
        return "+#{nr[:country_code]} #{nr[:area_code]} #{nr[:number]}"
      else
        return false
      end
    end
  
    def short
      "0#{area_code}/#{number}"      
    end
    
    def text=(pstring)
      @phone_number = PhoneSystem::Parser.new.parse(pstring)
    end
    
    def to_hash
      {
        :text         => text,
        :country_code => country_code,
        :country      => country,
        :area_code    => area_code,
        :area_name    => area_name,
        :number       => number,
        :long         => long,
        :short        => short
      }
    end
    
    def ==(other_phone_number)
      self.long = other_phone_number.long
    end
  
  end

end

# pn = PhoneSystem::PhoneNumber.new "0908420120"
# puts pn.inspect

