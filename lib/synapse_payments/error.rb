module SynapsePayments
  class Error < StandardError
    # Raised on a 4xx HTTP status code
    ClientError = Class.new(self)

    # Raised on the HTTP status code 400
    BadRequest = Class.new(ClientError)

    # Raised on the HTTP status code 401
    Unauthorized = Class.new(ClientError)

    # Raised on the HTTP status code 402
    RequestDeclined = Class.new(ClientError)

    # Raised on the HTTP status code 403
    Forbidden = Class.new(ClientError)

    # Raised on the HTTP status code 404
    NotFound = Class.new(ClientError)

    # Raised on the HTTP status code 406
    NotAcceptable = Class.new(ClientError)

    # Raised on the HTTP status code 409
    Conflict = Class.new(ClientError)

    # Raised on the HTTP status code 415
    UnsupportedMediaType = Class.new(ClientError)

    # Raised on the HTTP status code 422
    UnprocessableEntity = Class.new(ClientError)

    # Raised on the HTTP status code 429
    TooManyRequests = Class.new(ClientError)

    # Raised on a 5xx HTTP status code
    ServerError = Class.new(self)

    # Raised on the HTTP status code 500
    InternalServerError = Class.new(ServerError)

    # Raised on the HTTP status code 502
    BadGateway = Class.new(ServerError)

    # Raised on the HTTP status code 503
    ServiceUnavailable = Class.new(ServerError)

    # Raised on the HTTP status code 504
    GatewayTimeout = Class.new(ServerError)

    ERRORS = {
      400 => SynapsePayments::Error::BadRequest,
      401 => SynapsePayments::Error::Unauthorized,
      402 => SynapsePayments::Error::RequestDeclined,
      403 => SynapsePayments::Error::Forbidden,
      404 => SynapsePayments::Error::NotFound,
      406 => SynapsePayments::Error::NotAcceptable,
      409 => SynapsePayments::Error::Conflict,
      415 => SynapsePayments::Error::UnsupportedMediaType,
      422 => SynapsePayments::Error::UnprocessableEntity,
      429 => SynapsePayments::Error::TooManyRequests,
      500 => SynapsePayments::Error::InternalServerError,
      502 => SynapsePayments::Error::BadGateway,
      503 => SynapsePayments::Error::ServiceUnavailable,
      504 => SynapsePayments::Error::GatewayTimeout,
    }

    # The SynapsePay API Error Code
    #
    # @return [Integer]
    attr_reader :code

    # The JSON HTTP response in Hash form
    #
    # @return [Hash]
    attr_reader :response

    class << self
      # Create a new error from an HTTP response
      #
      # @param body [String]
      # @param code [Integer]
      # @return [SynapsePayments::Error]
      def error_from_response(body, code)
        klass = ERRORS[code] || SynapsePayments::Error
        message, error_code = parse_error(body)
        klass.new(message: message, code: error_code, response: body)
      end

    private

      def parse_error(body)
        if body.nil? || body.empty?
          ['', nil]
        elsif body.is_a?(Hash) && body[:error].is_a?(Hash)
          [body[:error][:en], body[:error_code]]
        else
          [body.to_s, nil]
        end
      end

    end

    # Initializes a new Error object
    #
    # @param message [Exception, String]
    # @param code [Integer]
    # @param response [Hash]
    # @return [SynapsePayments::Error]
    def initialize(message: '', code: nil, response: {})
      super(message)
      @code = code
      @response = response
    end
  end
end
