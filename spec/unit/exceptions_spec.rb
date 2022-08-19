require_relative '_lib'

describe RestMan::Exception do
  it "returns a 'message' equal to the class name if the message is not set, because 'message' should not be nil" do
    e = RestMan::Exception.new
    expect(e.message).to eq "RestMan::Exception"
  end

  it "returns the 'message' that was set" do
    e = RestMan::Exception.new
    message = "An explicitly set message"
    e.message = message
    expect(e.message).to eq message
  end

  it "sets the exception message to ErrorMessage" do
    expect(RestMan::ResourceNotFound.new.message).to eq 'Not Found'
  end

  it "contains exceptions in RestMan" do
    expect(RestMan::Unauthorized.new).to be_a_kind_of(RestMan::Exception)
    expect(RestMan::ServerBrokeConnection.new).to be_a_kind_of(RestMan::Exception)
  end
end

describe RestMan::ServerBrokeConnection do
  it "should have a default message of 'Server broke connection'" do
    e = RestMan::ServerBrokeConnection.new
    expect(e.message).to eq 'Server broke connection'
  end
end

describe RestMan::RequestFailed do
  before do
    @response = double('HTTP Response', :code => '502')
  end

  it "stores the http response on the exception" do
    response = "response"
    begin
      raise RestMan::RequestFailed, response
    rescue RestMan::RequestFailed => e
      expect(e.response).to eq response
    end
  end

  it "http_code convenience method for fetching the code as an integer" do
    expect(RestMan::RequestFailed.new(@response).http_code).to eq 502
  end

  it "http_body convenience method for fetching the body (decoding when necessary)" do
    expect(RestMan::RequestFailed.new(@response).http_code).to eq 502
    expect(RestMan::RequestFailed.new(@response).message).to eq 'HTTP status code 502'
  end

  it "shows the status code in the message" do
    expect(RestMan::RequestFailed.new(@response).to_s).to match(/502/)
  end
end

describe RestMan::ResourceNotFound do
  it "also has the http response attached" do
    response = "response"
    begin
      raise RestMan::ResourceNotFound, response
    rescue RestMan::ResourceNotFound => e
      expect(e.response).to eq response
    end
  end

  it 'stores the body on the response of the exception' do
    body = "body"
    stub_request(:get, "www.example.com").to_return(:body => body, :status => 404)
    begin
      RestMan.get "www.example.com"
      raise
    rescue RestMan::ResourceNotFound => e
      expect(e.response.body).to eq body
    end
  end
end

describe "backwards compatibility" do
  it 'aliases RestMan::NotFound as ResourceNotFound' do
    expect(RestMan::ResourceNotFound).to eq RestMan::NotFound
  end

  it 'aliases old names for HTTP 413, 414, 416' do
    expect(RestMan::RequestEntityTooLarge).to eq RestMan::PayloadTooLarge
    expect(RestMan::RequestURITooLong).to eq RestMan::URITooLong
    expect(RestMan::RequestedRangeNotSatisfiable).to eq RestMan::RangeNotSatisfiable
  end

  it 'subclasses NotFound from RequestFailed, ExceptionWithResponse' do
    expect(RestMan::NotFound).to be < RestMan::RequestFailed
    expect(RestMan::NotFound).to be < RestMan::ExceptionWithResponse
  end

  it 'subclasses timeout from RestMan::RequestTimeout, RequestFailed, EWR' do
    expect(RestMan::Exceptions::OpenTimeout).to be < RestMan::Exceptions::Timeout
    expect(RestMan::Exceptions::ReadTimeout).to be < RestMan::Exceptions::Timeout

    expect(RestMan::Exceptions::Timeout).to be < RestMan::RequestTimeout
    expect(RestMan::Exceptions::Timeout).to be < RestMan::RequestFailed
    expect(RestMan::Exceptions::Timeout).to be < RestMan::ExceptionWithResponse
  end

end
