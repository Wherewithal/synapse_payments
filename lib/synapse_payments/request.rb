module SynapsePayments
  class Request

    HEADERS = {
      'Accept'          => 'application/json',
      'User-Agent'      => "SynapsePaymentsRubyGem/#{SynapsePayments::VERSION}",
      'X-Ruby-Version'  => RUBY_VERSION,
      'X-Ruby-Platform' => RUBY_PLATFORM
    }

    def initialize(client:, method:, path:, oauth_key: nil, json: nil)
      @client = client
      @method = method
      @path = path
      @oauth_key = oauth_key
      @json = json
    end

    def perform
      options_key = @method == :get ? :params : :json
      response = http_client.public_send(@method, "#{@client.api_base}#{@path}", options_key => @json)
      response_body = symbolize_keys!(response.parse)
      fail_or_return_response_body(response.code, response_body)
    end

    def http_client
      headers = HEADERS.merge({
        'X-SP-GATEWAY' => "#{@client.client_id}|#{@client.client_secret}",
        'X-SP-USER' => "#{@oauth_key}|",
        'X-SP-USER-IP' => ''
      })
      HTTP.headers(headers).timeout(write: 2, connect: 5, read: 10)
    end

    def symbolize_keys!(object)
      if object.is_a?(Array)
        object.each_with_index do |val, index|
          object[index] = symbolize_keys!(val)
        end
      elsif object.is_a?(Hash)
        object.keys.each do |key|
          object[key.to_sym] = symbolize_keys!(object.delete(key))
        end
      end
      object
    end

    def fail_or_return_response_body(code, body)
      if code < 200 || code >= 206
        error = SynapsePayments::Error.error_from_response(body, code)
        fail(error)
      end
      body
    end

  end
end
