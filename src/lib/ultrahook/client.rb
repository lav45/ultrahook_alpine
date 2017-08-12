require 'uri'
require 'net/http'
require 'json'
require 'base64'
require 'optparse'
require 'openssl'
require 'net/http/persistent'
require 'logger'

$stdout.sync = true
LOG = Logger.new(STDOUT)

module UltraHook
  class Client
    def start(*args)
      @options = {}
      LOG.info "Ultrahook Paolo's Mod"
      optparse = OptionParser.new do |o|
        o.banner = "Usage: ultrahook [options] <subdomain> <destination>"

        o.on("-k", "--key <api key>", String, "API Key") do |key|
          @options["key"] = key
        end

        o.on_tail("-h", "--help", "Display this help") do
          puts o
          exit
        end

        o.on("-V", "--version", "Display client version") do
          puts "UltraHook client version: #{UltraHook::VERSION}"
          exit
        end
      end
      optparse.parse!(args)

      if @options["key"].nil? || @options["key"] == ""
        @options["key"] = ENV["ULTRAHOOK_API_KEY"]
      end

      if @options["key"].nil? || @options["key"] == ""
        path = File.expand_path("~/.ultrahook")
        if File.readable?(path)
          if matchdata = /api_key:\s*([^\s]+)/.match(IO.read(path))
            @options["key"] = matchdata.captures[0]
          end
        end
      end

      if @options["key"].nil? || @options["key"] == ""
        error "An API key must be provided.  Get one from http://www.ultrahook.com"
      end

      if args.size != 2
        puts optparse
        exit
      end

      @options["host"] = args[0].downcase
      error "Subdomain can only contain alphanumeric characters and hyphen (-)" unless @options["host"] =~ /^[[:alnum:]\-]+$/
      error "Subdomain cannot start or end with hyphens" if @options["host"] =~ /^\-/ || @options["host"] =~ /\-$/
      error "Subdomain cannot contain consecutive hyphens" if @options["host"] =~ /\-\-/

      @options["destination"] = parse_destination(args[1])

      retrieve_config
      init_stream
    end

    def parse_destination(dest)
      if dest =~ /^\d+/
        "http://localhost:#{dest}"
      elsif dest =~ /^[[:alnum:]\.\-]+:\d+$/
        "http://#{dest}"
      elsif dest =~ /^[[:alnum:]\.\-]+$/
        "http://#{dest}"
      elsif dest =~ /^https?:\/\//
        dest
      else
        error "Cannot parse destination url"
      end
    end

    def process(msg)
      begin
        payload = JSON.parse(Base64.decode64(msg))
        LOG.info "#{payload}"
      rescue
        error "Cannot communicate with server."
      end

      method_name = "process_#{payload["type"]}"
      send(method_name, payload) if respond_to?(method_name)
    end

    def process_init(payload)
      LOG.info "Forwarding activated..."
      LOG.info "http://#{@options["host"]}.#{@namespace}.ultrahook.com -> #{@options["destination"]}"
    end

    def process_error(payload)
      error payload["message"]
    end

    def process_warning(payload)
      LOG.warn "Warning: "+payload["message"]
    end

    def full_path(uri)
      return "/" if uri.path == "" && uri.query == ""
      return "/?#{uri.query}" if uri.path == "" && uri.query != ""
      return "#{uri.path}" if uri.path != "" && uri.query == ""
      return "#{uri.path}?#{uri.query}" if uri.path != "" && uri.query != ""
      raise "huh? this is impossible!"
    end

    def process_request(payload)
      uri = URI("#{@options["destination"]}#{payload["path"]}?#{payload["query"]}")
      response = http_post(uri, payload["body"], payload["headers"])

      LOG.info "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] POST #{uri.scheme}://#{uri.host}:#{uri.port}#{full_path(uri)} - #{response.code}"
    end

    def http_post(uri, data="", headers={})
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http.post(full_path(uri), data, headers)
    end

    def retrieve_config
      response = http_post(URI("http://www.ultrahook.com/init"), "key=#{@options["key"]}&host=#{@options["host"]}&version=#{UltraHook::VERSION}")

      error "Could not retrieve config from server: #{response.code}" if response.code.to_i != 200

      payload = JSON.parse(response.body)
      if payload["success"] == true
        @stream_url = payload["url"]
        @namespace = payload["namespace"]

        LOG.info "Authenticated as #{@namespace}"
      else
        error payload["error"]
      end
    end

    def init_stream
      uri = URI(@stream_url)
      http = Net::HTTP::Persistent.new
      http.idle_timeout = 10
      http.max_requests = 0
      http.keep_alive = 15
      begin
      LOG.info "Starting long poll from Ultrahook servers"
      response = http.request uri do |response|
            io = ""
            response.read_body do |chunk|
              io += chunk

              if idx = io.index("\n\n")
                msg = io.slice!(0, idx+2)
                # LOG.info "-----#{msg}"
                process(msg)
              end
            end
          end
      rescue Net::HTTP::Persistent::Error => e 
        LOG.error e.message   
        LOG.error "Connection closed"
        http.shutdown
        init_stream
      rescue Interrupt
        LOG.error "Interrupt signal received"
        http.shutdown 
      rescue Exception => e  
        LOG.error "Generic error"
        LOG.error "#{e.class}" 
        http.shutdown 
        retrieve_config 
        init_stream
      end
    end

    def error(msg)
      LOG.error "Error: #{msg}"
      exit -1
    end
  
  end
end
