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
      
      # Enable logging
      @enabled = true
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
    # <log_directory>/raw/<request_number>
    #
    # A symbolic link will be made from that directory to:
    #
    # @param [Net::HTTP] http  the object sending the request
    # @param [Net::HTTP::Request] request  the request being logged
    #
    # @return [Fixnum]  the sequential identifier for this request
    def self.log_request(http, request)
      # Retrieve the request identifier
      request_id = @next_id
      @next_id += 1
      
      # Create log directory
      dir = "#{log_directory}/raw/0"
      FileUtils.mkdir_p(dir)
      
      # Write request to file
      File.open("#{dir}/request", 'w') do |file|
        # Write method and path
        file.write("#{request.method} #{request.path} HTTP/1.1\n")
        
        # Write headers
        connection = *request.get_fields('Connection') || 'close'
        request.each_capitalized do |header_name, header_value|
          if header_name != 'Connection'
            file.write("#{header_name}: #{header_value}\n")
          end
        end
        file.write("Connection: #{connection}\n")
        file.write("Host: #{http.address}:#{http.port}\n")
        file.write("\n")
        
        # Write body
        file.write(request.body) unless request.body.nil?
      end
    end
  end
end