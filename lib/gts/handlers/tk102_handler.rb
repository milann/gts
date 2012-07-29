module Gts

  class TK102Handler < AbstractGPSTrackerHandler
    
    def parse(raw_data)
      raw_data = raw_data.gsub( /(^[\s\t\r\n]+|[\s\t\r\n]+$)/, '' )
      attrs = raw_data.split(",")
      raise CantParseGPSData if attrs.size != 18 || attrs[2] != "GPRMC"
      datetime = parse_datetime attrs[0]
      begin
        phone = PhoneSystem::PhoneNumber.new(attrs[1]).long
      rescue PhoneSystem::PhoneSystemError
        phone = attrs[1]
      end
      gps_time = attrs[3].scan(/(\d{2})(\d{2})(\d{2})\.(\d{3})/).first
      gps_time = "#{gps_time[0]}:#{gps_time[1]}:#{gps_time[2]}.#{gps_time[3]}"
      gps_date = attrs[11].scan(/([0-9]{2})([0-9]{2})([0-9]{2})/).first
      gps_year = Time.now.year.to_s[0..1] + gps_date[2]
      gps_date = "#{gps_year}-#{gps_date[1]}-#{gps_date[0]}"
      {
        :raw => raw_data,
        :datetime => datetime,
        :phone => phone,
        :gps_date => gps_date,
        :gps_time => gps_time,
        :gps_signal => (attrs[15] == 'F' ? 'full' : 'low'),
        :gps_fix => (attrs[4] == 'A' ? 'active' : 'invalid'),
        :lat => convert_nmea_coordinates(attrs[5], attrs[6]),
        :lng => convert_nmea_coordinates(attrs[7], attrs[8]),
        :bearing => attrs[10].to_i,
        :speed_knots => (attrs[9].to_f * 1000 ).round / 1000,
        :speed_kmh => ( attrs[9].to_f * 1.852 * 1000 ).round / 1000,
        :speed_mph => ( attrs[9].to_f * 1.151 * 1000 ).round / 1000,
        :imei => attrs[16].gsub('imei:', '')
      }
    end

    def self.devices
      %w( TK-102 TK-102B )
    end

    private

    # Vrati rozumnejsiu stringovu verziu casu 
    def parse_datetime(str)
      parts = str.scan(/.{2}/)
      year = Time.now.year.to_s[0..1] + parts[0]
      month = parts[1]
      day = parts[2]
      hour = parts[3]
      minute = parts[3]
      "#{year}-#{month}-#{day} #{hour}:#{minute}"
    end


    def convert_nmea_coordinates(one, two)
      minutes = one[-7..-1]
      degrees = one.gsub(minutes, "")
      one = degrees.to_i + minutes.to_f/60
      if two == "S" || two == "W"
        one = -one
      end
      one
    end

  end

end

Gts::TK102Handler.register!
