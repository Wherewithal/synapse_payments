module SynapsePayments
  class Subscriptions

    def initialize(client)
      @client = client
    end

    def all
      @client.get(path: '/subscriptions')
    end

    def create(url:, scope:)
      data = {
        url: url,
        scope: scope
      }

      @client.post(path: "/subscriptions", json: data)
    end

    def find(id)
      @client.get(path: "/subscriptions/#{id}")
    end

    def update(id, data)
      @client.patch(path: "/subscriptions/#{id}", json: data)
    end

  end

end
