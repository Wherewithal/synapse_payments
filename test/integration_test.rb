require 'test_helper'

class IntegrationTest < Minitest::Test

  def setup
    skip if ENV['USER_ID'].nil? || ENV['USER_ID'].empty?

    disable_vcr!

    @fingerprint = ENV.fetch('SYNAPSE_PAYMENTS_FINGERPRINT')
    @user_id = ENV['USER_ID']
    @user = authenticated_client.users.find(@user_id)
    @user_client = authenticated_client.users.authenticate_as(id: @user_id, refresh_token: @user[:refresh_token], fingerprint: @fingerprint)
  end

  def teardown
    skip if ENV['USER_ID'].nil? || ENV['USER_ID'].empty?

    @user_id = nil
    @user = nil
    @user_client = nil
    @fingerprint = nil

    enable_vcr!
  end

  def test_institutions
    response = authenticated_client.institutions

    assert_equal 16, response.size
    assert_equal 'Ally', response[0][:bank_name]
    assert_equal 'Bank of America', response[1][:bank_name]
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
    refute_predicate user[:legal_names], :empty?
  end

  def test_create_user_with_fingerprint_and_data
    user = authenticated_client.users.create(name: 'John Doe', email: 'john@test.com', phone: '123-456-8790', fingerprint: @fingerprint)
    user_client = authenticated_client.users.authenticate_as(id: user[:_id], refresh_token: user[:refresh_token], fingerprint: @fingerprint)

    refute_nil user_client.expires_at
    refute_nil user_client.expires_in
    refute_nil user_client.refresh_expires_in
    refute_nil user_client.refresh_token

    response = user_client.nodes.all
    assert response[:success]

    bank = user_client.add_bank_account(
      name: 'John Doe',
      account_number: '123456786',
      routing_number: '051000017',
      category: 'PERSONAL',
      type: 'CHECKING'
    )
    assert bank[:success]

    node_id = bank[:nodes].first[:_id]

    response = user_client.nodes(node_id).transactions.all
    assert response[:success]

    data = {
      type: 'SYNAPSE-US',
      info: {
        nickname: 'My First Integration Test Synapse Wallet'
      },
      extra: {
        supp_id: 123456
      }
    }

    node = user_client.nodes.create(data)

    response = user_client.nodes.all
    assert response[:success]
    assert_equal 3, response[:nodes].size

    transaction = user_client.send_money(
      from: bank[:nodes].first[:_id],
      to: node[:nodes].first[:_id],
      to_node_type: 'SYNAPSE-US',
      amount: 24.00,
      currency: 'USD',
      ip_address: '192.168.0.1',
      supp_id: '4321'
    )
  end

  def test_authenticate_as
    user_client = authenticated_client.users.authenticate_as(id: @user_id, refresh_token: @user[:refresh_token], fingerprint: @fingerprint)

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

    refute_predicate user[:_id], :empty?
  end

  def test_add_document_with_kba_answer
    response = @user_client.add_document(
      birthdate: Date.parse('1970/3/14'),
      first_name: 'John',
      last_name: 'Doe',
      street: '1 Infinite Loop',
      postal_code: '95014',
      country_code: 'US',
      document_type: 'SSN',
      document_value: '3333'
    )

    user = @user_client.answer_kba(
      question_set_id: response[:question_set][:id],
      answers: [
  			{ question_id: 1, answer_id: 1 },
  			{ question_id: 2, answer_id: 1 },
  			{ question_id: 3, answer_id: 1 },
  			{ question_id: 4, answer_id: 1 },
  			{ question_id: 5, answer_id: 1 }
      ]
    )
  end

  def test_add_document_failure_with_attached_photo_id
    begin
      response = @user_client.add_document(
        birthdate: Date.parse('1970/3/14'),
        first_name: 'John',
        last_name: 'Doe',
        street: '1 Infinite Loop',
        postal_code: '95014',
        country_code: 'US',
        document_type: 'SSN',
        document_value: '1111'
      )
    rescue SynapsePayments::Error::Conflict => error
      # no identity found, validation not possible, submit photo ID
    end

    user = @user_client.attach_file(fixture_path('image.png'))

    refute_predicate user[:_id], :empty?
  end

  def test_add_bank_account
    response = @user_client.add_bank_account(name: 'Test Test', account_number: '72347235423', routing_number: '051000017', category: 'PERSONAL', type: 'CHECKING')

    assert response[:success]
    assert_equal 1, response[:nodes].size
    refute_predicate response[:nodes][0][:_id], :empty?
    assert_equal 'Test Test', response[:nodes][0][:info][:name_on_account]
    assert_equal 'PERSONAL', response[:nodes][0][:info][:type]
    assert_equal 'CHECKING', response[:nodes][0][:info][:class]
    assert_equal '5423', response[:nodes][0][:info][:account_num]
    assert_equal '0017', response[:nodes][0][:info][:routing_num]
    assert_equal 'ACH-US', response[:nodes][0][:type]

    @user_client.nodes.delete(response[:nodes].first[:_id])
  end

  def test_add_instant_verified_bank_account
    response = @user_client.add_bank_account(name: 'Test Test', account_number: '123456786', routing_number: '051000017', category: 'PERSONAL', type: 'CHECKING')

    assert response[:success]
    assert_equal 1, response[:nodes].size
    refute_predicate response[:nodes][0][:_id], :empty?
    assert_equal 'Test Test', response[:nodes][0][:info][:name_on_account]
    assert_equal 'PERSONAL', response[:nodes][0][:info][:type]
    assert_equal 'CHECKING', response[:nodes][0][:info][:class]
    assert_equal '6786', response[:nodes][0][:info][:account_num]
    assert_equal '0017', response[:nodes][0][:info][:routing_num]

    @user_client.nodes.delete(response[:nodes].first[:_id])
  end

  def test_bank_login
    bank = @user_client.bank_login(bank_name: 'fake', username: 'synapse_nomfa', password: 'test1234')

    assert_equal 2, bank[:nodes].size
    assert_equal 'CREDIT-AND-DEBIT', bank[:nodes][0][:allowed]
    assert_equal '8901', bank[:nodes][0][:info][:account_num]
    assert_equal 'CREDIT-AND-DEBIT', bank[:nodes][1][:allowed]
    assert_equal '8902', bank[:nodes][1][:info][:account_num]
  end

  def test_bank_login_with_mfa
    bank = @user_client.bank_login(bank_name: 'fake', username: 'synapse_good', password: 'test1234')

    assert bank[:success]
    assert_nil bank[:nodes]
    refute_predicate bank[:mfa][:access_token], :empty?
    refute_predicate bank[:mfa][:message], :empty?

    bank = @user_client.verify_mfa(access_token: bank[:mfa][:access_token], answer: 'wrong answer')

    assert_nil bank[:nodes]
    refute_predicate bank[:mfa][:access_token], :empty?
    refute_predicate bank[:mfa][:message], :empty?

    bank = @user_client.verify_mfa(access_token: bank[:mfa][:access_token], answer: 'test_answer')

    assert bank[:success]
    assert_equal 2, bank[:nodes].size

    @user_client.nodes.delete(bank[:nodes].first[:_id])
  end

  def test_sending_money
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
    first_node = node[:nodes].first

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
    second_node = node2[:nodes].first

    transaction = @user_client.send_money(from: first_node[:_id], to: second_node[:_id], to_node_type: 'SYNAPSE-US', amount: 24.00, currency: 'USD', ip_address: '192.168.0.1', supp_id: '123')

    refute_predicate transaction[:_id], :empty?
    assert_equal 24.0, transaction[:amount][:amount]
    assert_equal 'USD', transaction[:amount][:currency]
    assert_equal '192.168.0.1', transaction[:extra][:ip]
    assert_equal '123', transaction[:extra][:supp_id]
    assert_equal first_node[:_id], transaction[:from][:id]
    assert_equal second_node[:_id], transaction[:to][:id]

    @user_client.nodes.delete(first_node[:_id])
    @user_client.nodes.delete(second_node[:_id])
  end

  def test_subscriptions
    response = authenticated_client.subscriptions.create(url: 'http://requestb.in/15zo81v1', scope: ['USERS|PATCH'])

    refute_predicate response[:_id], :empty?
    assert response[:is_active]
    assert_equal 'http://requestb.in/15zo81v1', response[:url]
    assert_equal ['USERS|PATCH'], response[:scope]

    response = authenticated_client.subscriptions.find(response[:_id])

    refute_predicate response[:_id], :empty?
    assert response[:is_active]
    assert_equal 'http://requestb.in/15zo81v1', response[:url]
    assert_equal ['USERS|PATCH'], response[:scope]

    response = authenticated_client.subscriptions.update(response[:_id], is_active: false, url: 'http://requestb.in/15zo81v1', scope: [])

    refute_predicate response[:_id], :empty?
    refute response[:is_active]
    assert_equal 'http://requestb.in/15zo81v1', response[:url]
    assert_predicate response[:scope], :empty?

    response = authenticated_client.subscriptions.all

    assert response[:success]
    assert response[:page] >= 1
    assert response[:page_count] >= 0
    refute_predicate response[:subscriptions], :empty?
    assert response[:subscriptions_count] >= 1
  end

end
