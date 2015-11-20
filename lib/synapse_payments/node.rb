module SynapsePayments
  class Node

    attr_reader :transactions

    def initialize(client, user_id, node_id, oauth_key, fingerprint)
      @client = client
      @transactions = Transactions.new(@client, user_id, node_id, oauth_key, fingerprint)
    end

  end

end
