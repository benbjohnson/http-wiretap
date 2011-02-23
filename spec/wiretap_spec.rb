require File.join(File.dirname(File.expand_path(__FILE__)), 'spec_helper')

describe HTTP::Wiretap do
  ##############################################################################
  # Setup
  ##############################################################################

  before do
    HTTP::Wiretap.restart()
    
    @http = Net::HTTP.new('localhost', 8080);
  end

  def mock_file(contents)
    file = mock()
    contents.chomp!
    headers, body = *contents.split("\n\n")
    headers.each do |line|
      file.expects(:write).with("#{line.chomp}\r\n")
    end
    file.expects(:write).with("\r\n")
    file.expects(:write).with(body) unless body.nil?
    return file
  end
  
  def empty_mock_file(path)
    mock_file(
      "GET #{path} HTTP/1.1\n" +
      "Accept: */*\n" +
      "Connection: close\n" +
      "Host: localhost:8080\n" +
      "\n"
    )
  end

  ##############################################################################
  # Tests
  ##############################################################################

  it 'should log simple request' do
    FileUtils.expects(:mkdir_p).with('http-log/raw/0')
    File.expects(:open).with('http-log/raw/0/request', 'w').yields empty_mock_file('/index.html')
    
    request = Net::HTTP::Get.new('/index.html')
    HTTP::Wiretap.log_request(@http, request)
  end
  
  it 'should log multiple requests' do
    FileUtils.expects(:mkdir_p).with('http-log/raw/0')
    File.expects(:open).with('http-log/raw/0/request', 'w').yields empty_mock_file('/index.html')
    
    FileUtils.expects(:mkdir_p).with('http-log/raw/1')
    File.expects(:open).with('http-log/raw/1/request', 'w').yields empty_mock_file('/users')

    FileUtils.expects(:mkdir_p).with('http-log/raw/2')
    File.expects(:open).with('http-log/raw/2/request', 'w').yields empty_mock_file('/users/0/edit')

    HTTP::Wiretap.log_request(@http, Net::HTTP::Get.new('/index.html'))
    HTTP::Wiretap.log_request(@http, Net::HTTP::Get.new('/users'))
    HTTP::Wiretap.log_request(@http, Net::HTTP::Get.new('/users/0/edit'))
  end

  it 'should log request headers' do
    FileUtils.expects(:mkdir_p).with('http-log/raw/0')
    File.expects(:open).with('http-log/raw/0/request', 'w').yields mock_file(
      <<-BLOCK.unindent
        GET /index.html HTTP/1.1
        Accept: */*
        Cache-Control: no-cache
        Content-Type: text/plain
        Connection: close
        Host: localhost:8080
        
      BLOCK
    )
    
    headers = {'Cache-Control' => 'no-cache', 'Content-Type' => 'text/plain'}
    HTTP::Wiretap.log_request(@http, Net::HTTP::Get.new('/index.html', headers))
  end
  
  it 'should log request body' do
    FileUtils.expects(:mkdir_p).with('http-log/raw/0')
    File.expects(:open).with('http-log/raw/0/request', 'w').yields mock_file(
      <<-BLOCK.unindent
        POST /index.html HTTP/1.1
        Accept: */*
        Connection: close
        Host: localhost:8080
        Content-Type: application/x-www-form-urlencoded
        
        foo=bar
      BLOCK
    )
    
    request = Net::HTTP::Post.new('/index.html')
    request.set_form_data({'foo' => 'bar'})
    HTTP::Wiretap.log_request(@http, request)
  end
  
end