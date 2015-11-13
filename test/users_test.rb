require 'test_helper'

class UsersTest < Minitest::Test

  def setup
    enable_vcr!
  end

  def test_users_all
    VCR.use_cassette('users_all') do
      users = authenticated_client.users.all

      assert_equal '200', users[:http_code]
      assert_equal '0', users[:error_code]
      assert users[:success]
      refute_nil users[:users]
    end
  end

  def test_user_find
    VCR.use_cassette('users_find') do
      user = authenticated_client.users.find('5641019d86c273308e8193f1')

      refute_predicate user[:_id], :empty?
      refute_predicate user[:refresh_token], :empty?
      assert_equal ['Javier Julio'], user[:legal_names]
    end
  end

  def test_authenticate_as
    VCR.use_cassette('users_find') do
      user = authenticated_client.users.find('5641019d86c273308e8193f1')

      VCR.use_cassette('oauth_refresh_token') do
        user_client = authenticated_client.users.authenticate_as(id: '5641019d86c273308e8193f1', refresh_token: user[:refresh_token])
      end
    end
  end

end
