require File.join(File.dirname(File.expand_path(__FILE__)), 'spec_helper')

describe HTTP::Wiretap do
  ##############################################################################
  # Setup
  ##############################################################################

  before do
    HTTP::Wiretap.restart()
    
    @http = Net::HTTP.new('localhost', 8080);
  end


  ##############################################################################
  # Tests
  ##############################################################################

  it 'should log simple request' do
    request_file = mock()
    request_file.expects(:write).with("GET /index.html HTTP/1.1\r\n")
    request_file.expects(:write).with("Accept: */*\r\n")
    request_file.expects(:write).with("Connection: close\r\n")
    request_file.expects(:write).with("Host: localhost:8080\r\n")
    request_file.expects(:write).with("\r\n")
    
    FileUtils.expects(:mkdir_p).with('http-log/raw/0')
    File.expects(:open).with('http-log/raw/0/request', 'w').yields(request_file)
    
    request = Net::HTTP::Get.new('/index.html')
    HTTP::Wiretap.log_request(@http, request)
  end
end