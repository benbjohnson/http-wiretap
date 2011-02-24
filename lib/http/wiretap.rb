dir = File.join(File.dirname(File.expand_path(__FILE__)), '..')
$:.unshift(dir)

require 'http/ext/net_http'
require 'fileutils'

module HTTP
  class Wiretap
    VERSION = '0.1.0'
    
    ############################################################################
    # Static Initializers
    ############################################################################
    
    @enabled = false 


    ############################################################################
    # Static Properties
    ############################################################################
    
    # A flag stating if wiretap has started
    def self.enabled
      @enabled
    end


    # The root directory where logs are stored.
    def self.log_directory
      @log_directory || 'http-log'
    end

    # Sets the root directory where logs are stored.
    def self.log_directory=(dir)
      @log_directory = dir
    end


    ############################################################################
    # Static Methods
    ############################################################################
    
    # Begins logging requests and responses.
    def self.start()
      # Reset the sequential request identifier
      @next_id = 0
      @host_request_paths = {}
      @host_request_next_id = {}
      
      # Enable logging
      @enabled = true
      
      # Clear log directory
      FileUtils.rm_rf(log_directory)
    end

    # Stops logging requests and responses.
    def self.stop()
      # Disable logging
      @enabled = false
    end

    # Stops logging and then restarts.
    def self.restart()
      self.stop()
      self.start()
    end
    
    # Logs a request's headers and body to a file. The file will be written to: 
    #
    # <log_directory>/raw/<request_number>/request
    #
    # A symbolic link will be made from that directory to the `host/` directory.
    #
    # @param [Net::HTTP] http  the object sending the request
    # @param [Net::HTTP::Request] request  the request being logged
    #
    # @return [Fixnum]  the sequential identifier for this request
    def self.log_request(http, request)
      return unless @enabled
      
      # Retrieve the request identifier
      request_id = @next_id
      @next_id += 1
      
      # Create raw log directory
      raw_dir = File.expand_path("#{log_directory}/raw/#{request_id}")
      ::FileUtils.mkdir_p(raw_dir)
      
      # Write request to file
      File.open("#{raw_dir}/request", 'w') do |file|
        # Write method and path
        file.write("#{request.method} #{request.path} HTTP/1.1\r\n")
        
        # Write headers
        connection = *request.get_fields('Connection') || 'close'
        request.each_capitalized do |header_name, header_value|
          if header_name != 'Connection'
            file.write("#{header_name}: #{header_value}\r\n")
          end
        end
        file.write("Connection: #{connection}\r\n")
        file.write("Host: #{http.address}:#{http.port}\r\n")
        file.write("\r\n")
        
        # Write body
        file.write(request.body) unless request.body.nil?
      end
      
      # Link to host-based log
      host_request_name = "#{http.address}#{request.path}"
      host_request_id = @host_request_next_id[host_request_name] ||= 0
      @host_request_next_id[host_request_name] += 1
      host_dir = File.expand_path("#{log_directory}/host/#{host_request_name}/#{host_request_id}")
      @host_request_paths[request_id] = host_dir
      ::FileUtils.mkdir_p(host_dir)
      ::FileUtils.ln_sf("#{raw_dir}/request", "#{host_dir}/request")

      return request_id
    end

    # Logs a response's headers and body to a file. The file will be written to: 
    #
    # <log_directory>/raw/<request_number>/response
    #
    # A symbolic link will be made from that directory to the `host/` directory.
    #
    # @param [Net::HTTP] http  the object sending the request
    # @param [Net::HTTP::Request] request  the request being logged
    # @param [Fixnum] request_id  the sequential identifier for the request
    def self.log_response(http, response, request_id)
      return unless @enabled

      # Create log directory
      raw_dir = File.expand_path("#{log_directory}/raw/#{request_id}")
      ::FileUtils.mkdir_p(raw_dir)
      
      # Write response to file
      File.open("#{raw_dir}/response", 'w') do |file|
        file.write("HTTP/#{response.http_version} #{response.code}\r\n")

        # Write headers
        response.each_capitalized do |header_name, header_value|
          file.write("#{header_name}: #{header_value}\r\n")
        end
        file.write("\r\n")
        
        # Write body
        file.write(response.body) unless response.body.nil?
      end

      # Link to host-based log
      host_dir = @host_request_paths[request_id]
      ::FileUtils.mkdir_p(host_dir)
      ::FileUtils.ln_sf("#{raw_dir}/response", "#{host_dir}/response")
    end
  end
end