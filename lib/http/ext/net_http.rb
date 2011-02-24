require 'net/http'
require 'net/https'

module Net
  class HTTP
    def request_with_wiretap(request, body = nil, &block)
      request_id = nil
      
      # Log request
      if ::HTTP::Wiretap.enabled
        request_id = ::HTTP::Wiretap.log_request(self, request)
      end
      
      # Send request
      block_response = nil
      block_wrapper = lambda do |res|
        puts "inside: #{res}"
        block_response = res
        block.call(res) unless block.nil?
        res
      end
      return_response = request_without_wiretap(request, body, &block_wrapper)
      
      # Use whichever 
      response = nil
      response = return_response if return_response.is_a?(Net::HTTPResponse)
      response = block_response if response.nil?

      # Log response
      if ::HTTP::Wiretap.enabled
        ::HTTP::Wiretap.log_response(self, response, request_id)
      end
    end

    alias_method :request_without_wiretap, :request
    alias_method :request, :request_with_wiretap
  end
end
