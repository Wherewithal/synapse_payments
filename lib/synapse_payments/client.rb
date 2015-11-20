require 'http'

module SynapsePayments
  class Client

    API_TEST = 'https://sandbox.synapsepay.com/api/3'
    API_LIVE = 'https://synapsepay.com/api/3'

    attr_accessor :client_id, :client_secret, :sandbox_mode
    attr_reader :api_base, :users

    # Initializes a new Client object
    #
    # @param options [Hash]
    # @return [SynapsePayments::Client]
    def initialize(options={})
      @sandbox_mode = true

      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      yield(self) if block_given?

      @api_base = @sandbox_mode ? API_TEST : API_LIVE

      @users = Users.new(self)
    end

    # @return [Hash]
    def credentials
      {
        client_id: client_id,
        client_secret: client_secret
      }
    end

    # @return [Boolean]
    def credentials?
      credentials.values.all?
    end

    def get(path:, oauth_key: nil, fingerprint: nil)
      Request.new(client: self, method: :get, path: path, oauth_key: oauth_key, fingerprint: fingerprint).perform
    end

    def post(path:, json:, oauth_key: nil, fingerprint: nil)
      Request.new(client: self, method: :post, path: path, oauth_key: oauth_key, fingerprint: fingerprint, json: json).perform
    end

    def patch(path:, json:, oauth_key: nil, fingerprint: nil)
      Request.new(client: self, method: :patch, path: path, oauth_key: oauth_key, fingerprint: fingerprint, json: json).perform
    end

    def delete(path:, oauth_key: nil, fingerprint: nil)
      Request.new(client: self, method: :delete, path: path, oauth_key: oauth_key, fingerprint: fingerprint).perform
    end

  end
end
