module SynapsePayments
  class Transactions

    def initialize(client, user_id, node_id, oauth_key)
      @client = client
      @user_id = user_id
      @node_id = node_id
      @oauth_key = oauth_key
    end

    def all
      @client.get(path: "/users/#{@user_id}/nodes/#{@node_id}/trans", oauth_key: @oauth_key)
    end

    def create(node_id:, node_type:, amount:, currency:, ip_address:, **args)
      data = {
        to: {
          type: node_type,
          id: node_id
        },
        amount: {
          amount: amount,
          currency: currency
        },
        extra: {
          ip: ip_address
        }.merge(args)
      }

      @client.post(path: "/users/#{@user_id}/nodes/#{@node_id}/trans", oauth_key: @oauth_key, json: data)
    end

    def delete(id)
      @client.delete(path: "/users/#{@user_id}/nodes/#{@node_id}/trans/#{id}", oauth_key: @oauth_key)
    end

    def find(id)
      @client.get(path: "/users/#{@user_id}/nodes/#{@node_id}/trans/#{id}", oauth_key: @oauth_key)
    end

    def update(id, data)
      @client.patch(path: "/users/#{@user_id}/nodes/#{@node_id}/trans/#{id}", oauth_key: @oauth_key, json: data)
    end

  end

end
