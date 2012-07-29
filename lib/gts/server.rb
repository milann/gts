require 'eventmachine'
require 'open-uri'
require 'json'
require 'gts'

DEFAULT_IMEI_HANDLERS = { "359585017718724" => "TK-102" } # IMEI nasej TK-102jky 
DEFAULT_IMEI_HANDLER_SOURCE = nil
 
module Gts

  module Server # TCP server

    @@tracker_requests_count = 0
    @@started_at = nil

    def logger
      Gts.logger
    end

    def self.logger
      Gts.logger
    end

    class GtsError < StandardError; end;
    class CantDetermineIMEI < GtsError; end;
    class DontKnowHowToHandleThisDevice < GtsError; end;

    def initialize
      @@imei_handlers ||= DEFAULT_IMEI_HANDLERS
      @@imei_handlers_source ||= DEFAULT_IMEI_HANDLER_SOURCE
      @@device_handlers = Gts.registered_handlers
      load_imei_handlers!
    end

    def post_init
      logger.info "New connection from #{client_ip_address}"
    end
    
    def receive_data data
      if data =~ /^%/
        handle_command(data.gsub(/^%\s*?/, ''))
      else
        handle_tracker_data(data)
      end
    end

    def self.start!(opts={})
      @@address = opts[:address]
      @@port = opts[:port]
      @@output_file = opts[:output_file]
      @@started_at ||= Time.now
      EventMachine::run {
        EventMachine::start_server @@address, @@port, self
        puts "Server started. Press Ctrl+C to stop."
        puts "Hunting for data..."
      }
      self
    end

    def self.stop!
      EventMachine::stop
      puts "Bye!"
    end

    def self.uptime
      sum =  Time.now - @@started_at
      days = (sum / (3600 * 24)).to_i
      hours = (sum / 3600 - (days * (3600 * 24))).to_i
      minutes = (sum / 60 - hours * 60).to_i
      seconds = (sum % 60).to_i
      "#{days}d #{hours}h #{minutes}m #{seconds}s"
    end

    def self.list_known_devices
      @@imei_handlers.map{ |k,v| "#{k}: #{v}" }.join "\n"
    end

    private

    def handle_command(command)
      begin
        command = command.strip
        output = Gts::Command.execute(command)
        send_data output + "\n"
        logger.info "Executed '#{command}' [from #{client_ip_address}]"
        logger.debug "Command output:\n#{output}"
      rescue Gts::Command::UnknownCommand
        send_data "Error: Unknown command\n"
        logger.error "Unknown command '#{command}' [from #{client_ip_address}]"
      end
    end

    def handle_tracker_data(data)
      begin
        parsed_data = parse_data(data)
        logger.info "Got correct data [from #{client_ip_address}, imei: #{parsed_data[:imei]}]"
        formatted_data = parsed_data.map{|k,v| "\t#{k}: #{v}\n" }.join
        logger.debug "Parsed data:\n" + formatted_data
        log_data_to_csv_file(parsed_data)
      rescue GtsError => e
        if parsed_data.is_a?(Hash) && parsed_data[:imei]
          imei = parsed_data[:imei]
        else
          imei = 'unknown'
        end
        logger.error "Got incorrect data [from #{client_ip_address}, imei: #{imei}]. Exception: #{e.to_s}"
        logger.debug "Incorrect data: #{data}"
      end
      close_connection
    end


    def client_ip_address
      get_peername[2,6].unpack('nC4')[1,4].join(".")
    end

    def log_data_to_csv_file(parsed_data)
      if @@output_file
        if !File.exists?(@@output_file) 
          File.open(@@output_file, "w") do |f|
            f.puts parsed_data.keys.map{ |k| k.to_s }.sort.join("\t") # hlavicka
          end
        end
        File.open(@@output_file, "a") do |f|
          pd = parsed_data.keys.map{ |k| k.to_s }.sort.map{|k| parsed_data[k.to_sym]}.join("\t")
          f.puts pd
        end
      end
    end

    def parse_data(data)
       imei = get_imei(data)
       if !known_imei?(imei)
         logger.info "Unknown IMEI, reloading IMEI handlers index."
         load_imei_handlers!
       end
       if known_imei?(imei)
         handler = determine_handler(imei).new
         handler.parse(data)
       else
         raise DontKnowHowToHandleThisDevice, "Don't know what handler to use for IMEI# #{imei}"
       end
    end

    def known_imei?(imei)
      !@@imei_handlers[imei].nil?
    end

    def determine_handler(imei)
      imei_handler_str = @@imei_handlers[imei]
      @@device_handlers[imei_handler_str]
    end

    # mozno by sme mohli priamo hadat typ zariadenia ked uz hadame imei,
    # no imei_handlers tabulka a imei je bezpecnejsia cesta
    def get_imei(data)
      if data =~ /imei:(\d{15}),/
        return $1
      else
        raise CantDetermineIMEI
      end
    end

    def load_imei_handlers!
      src = @@imei_handlers_source
      @@imei_handlers = {} unless @@imei_handlers.is_a? Hash
      return if src.nil? || src == ""
      if File.exists?(src) 
        json = File.open(src).read
      else
        json = open(src).read
      end
      @@imei_handlers.merge!(JSON.parse(json))
    end

  end

end 
