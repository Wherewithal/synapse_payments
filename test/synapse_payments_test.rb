require 'test_helper'

class SynapsePaymentsTest < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil ::SynapsePayments::VERSION
  end

  def test_client_is_configured_through_options
    client = SynapsePayments::Client.new(
      client_id: 'client_id',
      client_secret: 'client_secret',
      sandbox_mode: false
    )

    assert_equal client.client_id, 'client_id'
    assert_equal client.client_secret, 'client_secret'
    assert_equal client.sandbox_mode, false
    assert client.credentials?
  end

  def test_client_is_configured_with_block
    client = SynapsePayments::Client.new do |config|
      config.client_id = 'client_id'
      config.client_secret = 'client_secret'
      config.sandbox_mode = false
    end

    assert_equal client.client_id, 'client_id'
    assert_equal client.client_secret, 'client_secret'
    assert_equal client.sandbox_mode, false
    assert client.credentials?
  end

  def test_api_base_changes_based_on_test_mode
    client = SynapsePayments::Client.new(sandbox_mode: true)

    assert_equal client.sandbox_mode, true
    assert_equal client.api_base, 'https://sandbox.synapsepay.com/api/3'

    client = SynapsePayments::Client.new(sandbox_mode: false)

    assert_equal client.sandbox_mode, false
    assert_equal client.api_base, 'https://synapsepay.com/api/3'
  end

  def test_credentials?
    assert test_client.credentials?

    client = SynapsePayments::Client.new(client_id: 'client_id')

    refute client.credentials?
  end

end
