require 'test_helper'

class IntegrationTest < Minitest::Test

  def setup
    skip if ENV['USER_ID'].nil? || ENV['USER_ID'].empty?

    disable_vcr!

    @user_id = ENV['USER_ID']
    @user = authenticated_client.users.find(@user_id)
    @user_client = authenticated_client.users.authenticate_as(id: @user_id, refresh_token: @user[:refresh_token])
  end

  def teardown
    skip if ENV['USER_ID'].nil? || ENV['USER_ID'].empty?

    @user_id = nil
    @user = nil
    @user_client = nil

    enable_vcr!
  end

  def test_users_all
    users = authenticated_client.users.all

    assert_equal '200', users[:http_code]
    assert_equal '0', users[:error_code]
    assert users[:success]
    refute_nil users[:users]
  end

  def test_user_find
    user = authenticated_client.users.find(@user_id)

    refute_predicate user[:_id], :empty?
    refute_predicate user[:refresh_token], :empty?
    assert_equal ['Javier Julio'], user[:legal_names]
  end

  def test_authenticate_as
    user_client = authenticated_client.users.authenticate_as(id: @user_id, refresh_token: @user[:refresh_token])

    refute_predicate user_client.refresh_token, :empty?
  end

  def test_add_document_successful
    user = @user_client.add_document(
      birthdate: Date.parse('1970/3/14'),
      first_name: 'John',
      last_name: 'Doe',
      street: '1 Infinite Loop',
      postal_code: '95014',
      country_code: 'US',
      document_type: 'SSN',
      document_value: '2222'
    )

    puts '--- test_add_document_successful',user,''
  end

  def test_answer_kba
    user = @user_client.answer_kba(question_set_id: "557520ad343463000300005a", answers: [
			{ question_id: 1, answer_id: 1 },
			{ question_id: 2, answer_id: 1 },
			{ question_id: 3, answer_id: 1 },
			{ question_id: 4, answer_id: 1 },
			{ question_id: 5, answer_id: 1 }
    ])

    puts '--- test_answer_kba',user,''
  end

  def test_nodes_all
    nodes = @user_client.nodes.all
    puts '---- nodes',nodes,''
  end

  def test_add_bank_account
    bank = @user_client.add_bank_account(name: 'John Doe', account_number: '72347235423', routing_number: '051000017', category: 'PERSONAL', type: 'CHECKING')
    puts '---- add_bank_account',bank,''
    @user_client.nodes.delete(bank[:nodes].first[:_id])
  end

  def test_add_instant_verified_bank_account
    bank = @user_client.add_bank_account(name: 'John Doe', account_number: '123456786', routing_number: '051000017', category: 'PERSONAL', type: 'CHECKING')
    puts '---- add_bank_account',bank,''
    @user_client.nodes.delete(bank[:nodes].first[:_id])
  end

  def test_create_node
    data = {
      type: 'SYNAPSE-US',
      info: {
        nickname: 'My Integration Test Synapse Wallet'
      },
      extra: {
        supp_id: 123456
      }
    }

    node = @user_client.nodes.create(data)
    puts '---- create_node',node,''

    @user_client.nodes.delete(node[:nodes].first[:_id])
  end

  def test_send_money
    data = {
      type: 'SYNAPSE-US',
      info: {
        nickname: 'My First Integration Test Synapse Wallet'
      },
      extra: {
        supp_id: 123456
      }
    }

    node = @user_client.nodes.create(data)

    data = {
      type: 'SYNAPSE-US',
      info: {
        nickname: 'My Second Integration Test Synapse Wallet'
      },
      extra: {
        supp_id: 12345678
      }
    }

    node2 = @user_client.nodes.create(data)

    transaction = @user_client.send_money(from: node[:nodes].first[:_id], to: node2[:nodes].first[:_id], to_node_type: 'SYNAPSE-US', amount: 24.00, currency: 'USD', ip_address: '192.168.0.1')

    puts '---- test_send_money_to',transaction,''

    @user_client.nodes.delete(node[:nodes].first[:_id])
    @user_client.nodes.delete(node2[:nodes].first[:_id])
  end

end
