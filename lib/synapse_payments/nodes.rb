module SynapsePayments
  class Nodes

    def initialize(client, user_id, oauth_key)
      @client = client
      @user_id = user_id
      @oauth_key = oauth_key
    end

    def all
      @client.get(path: "/users/#{@user_id}/nodes", oauth_key: @oauth_key)
    end

    def find(id)
      @client.get(path: "/users/#{@user_id}/nodes/#{id}", oauth_key: @oauth_key)
    end

    def create(data)
      @client.post(path: "/users/#{@user_id}/nodes", oauth_key: @oauth_key, json: data)
    end

    def delete(id)
      @client.delete(path: "/users/#{@user_id}/nodes/#{id}", oauth_key: @oauth_key)
    end

  end

end
