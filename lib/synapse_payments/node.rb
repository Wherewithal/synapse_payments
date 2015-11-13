module SynapsePayments
  class Node

    attr_reader :transactions

    def initialize(client, user_id, node_id, oauth_key)
      @client = client
      @user_id = user_id
      @node_id = node_id
      @oauth_key = oauth_key
      @transactions = Transactions.new(@client, user_id, node_id, oauth_key)
    end

  end

end
