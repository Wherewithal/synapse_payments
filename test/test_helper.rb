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

def test_client
  SynapsePayments::Client.new do |config|
    config.client_id = 'client_id'
    config.client_secret = 'client_secret'
  end
end

def authenticated_client
  SynapsePayments::Client.new do |config|
    config.client_id = ENV['SYNAPSE_PAYMENTS_CLIENT_ID'] || 'client_id'
    config.client_secret = ENV['SYNAPSE_PAYMENTS_CLIENT_SECRET'] || 'client_secret'
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
