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
      response = request_without_wiretap(request, body, &block)

      # Log response
      if ::HTTP::Wiretap.enabled
        ::HTTP::Wiretap.log_response(self, response, request_id)
      end
    end

    alias_method :request_without_wiretap, :request
    alias_method :request, :request_with_wiretap
  end
end
