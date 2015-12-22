$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'synapse_payments'
require 'minitest/autorun'
require 'minitest/reporters'
require 'webmock/minitest'
require 'vcr'
require 'dotenv'

Dotenv.load

VCR.configure do |c|
  c.cassette_library_dir = "test/fixtures"
  c.hook_into :webmock
end

Minitest::Reporters.use!([Minitest::Reporters::SpecReporter.new])

TEST_ROOT = File.dirname(File.expand_path('.', __FILE__))

def fixture_path(file_name)
  "#{TEST_ROOT}/fixtures/#{file_name}"
end

def test_client
  SynapsePayments::Client.new do |config|
    config.client_id = 'client_id'
    config.client_secret = 'client_secret'
  end
end

def test_user_client(user_id:)
  SynapsePayments::UserClient.new(test_client, user_id, nil, {
    oauth_key: 'oauth_key',
    refresh_token: 'refresh_token',
    expires_at: '1447445562',
    expires_in: '7200',
    refresh_expires_in: 12
  })
end

def authenticated_client
  SynapsePayments::Client.new do |config|
    config.client_id = ENV.fetch('SYNAPSE_PAYMENTS_CLIENT_ID')
    config.client_secret = ENV.fetch('SYNAPSE_PAYMENTS_CLIENT_SECRET')
  end
end

def enable_vcr!
  VCR.turn_on!
  WebMock.disable_net_connect!
end

def disable_vcr!
  WebMock.allow_net_connect!
  VCR.turn_off!
end
