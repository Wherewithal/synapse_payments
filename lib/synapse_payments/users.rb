module SynapsePayments
  class Users

    def initialize(client)
      @client = client
    end

    def all
      @client.get(path: '/users')
    end

    def authenticate_as(id:, refresh_token:)
      response = @client.post(path: "/oauth/#{id}", json: { refresh_token: refresh_token })
      UserClient.new(@client, id, response)
    end

    def create(name:, email:, phone:, is_business: false, **args)
      data = {
        logins: email.is_a?(Array) ? email : [{ email: email }],
        phone_numbers: phone.is_a?(Array) ? phone : [phone],
        legal_names: name.is_a?(Array) ? name : [name],
        extra: {
          note: args[:note],
          supp_id: args[:supp_id],
          is_business: is_business
        }
      }

      @client.post(path: '/users', json: data)
    end

    def find(id)
      @client.get(path: "/users/#{id}")
    end

  end

end
