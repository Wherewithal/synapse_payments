module SynapsePayments
  class UserClient

    def initialize(client, user_id, response)
      @client = client
      @user_id = user_id
      @response = response
      @oauth_key = response[:oauth_key]

      response.each do |key, value|
        (class << self; self; end).class_eval do
          define_method key do |*args|
            response[key]
          end
        end
      end

      @nodes = Nodes.new(@client, user_id, oauth_key)
    end

    def user
      @client.get(path: "/users/#{@user_id}", oauth_key: @oauth_key)
    end

    def add_document(birthdate:, first_name:, last_name:, street:, postal_code:, country_code:, document_type:, document_value:)
      data = {
        doc: {
          birth_day: birthdate.day,
          birth_month: birthdate.month,
          birth_year: birthdate.year,
          name_first: first_name,
          name_last: last_name,
          address_street1: street,
          address_postal_code: postal_code,
          address_country_code: country_code,
          document_type: document_type,
          document_value: document_value
        }
      }

      @client.patch(path: "/users/#{@user_id}", oauth_key: @oauth_key, json: data)
    end

    def answer_kba(question_set_id:, answers:)
      data = {
        doc: {
          question_set_id: question_set_id,
          answers: answers
        }
      }

      @client.patch(path: "/users/#{@user_id}", oauth_key: @oauth_key, json: data)
    end

    # Adds a bank account by creating a node of node type ACH-US.
    #
    # @param name [String] the name of the account holder
    # @param account_number [String]
    # @param routing_number [String]
    # @param category [String] the account category, `personal` or `business`
    # @param type [String] the account type, `checking` or `savings`
    # @return [Hash]
    def add_bank_account(name:, account_number:, routing_number:, category:, type:, **args)
      data = {
        type: 'ACH-US',
        info: {
          nickname: args[:nickname] || name,
          name_on_account: name,
          account_num: account_number,
          routing_num: routing_number,
          type: category,
          class: type
        },
        extra: {
          supp_id: args[:supp_id]
        }
      }
      nodes.create(data)
    end

    def send_money(from:, to:, to_node_type:, amount:, currency:, ip_address:)
      nodes(from).transactions.create(node_id: to, node_type: to_node_type, amount: amount, currency: currency, ip_address: ip_address)
    end

    def nodes(id=nil)
      if id.nil?
        @nodes
      else
        Node.new(@client, @user_id, id, @oauth_key)
      end
    end

  end
end
