# The SynapsePayments Ruby Gem

A tested Ruby interface to the [SynapsePay v3 API](http://docs.synapsepay.com/v3.1). Note: Requires **Ruby 2.1 and up**. Not all API actions are supported. Find out more in the TODO section.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'synapse_payments'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install synapse_payments

To try out the gem and experiment, you're better off following the development instructions.

## Usage

TODO: Write usage instructions here

## Development

1. Clone the repo: `git clone https://github.com/javierjulio/synapse_payments.git`
2. Use Ruby 2.1 and up. If you need to install use [rbenv](https://github.com/sstephenson/rbenv) and [ruby-build](https://github.com/sstephenson/ruby-build) and then run:

        gem update --system
        gem update
        gem install bundler --no-rdoc --no-ri

3. From project root run `./bin/setup` script
4. Run `./bin/console` for an interactive prompt with an authenticated client for you to experiment:

  ```ruby
  users = client.users.all
  puts users
  # => {...
  ```

### TODO

* add fake values for client_id, client_secret, user_id, etc. in all fixtures
* add pagination/querying to `users.all`, `nodes.all`, and `transactions.all`
* add support for new `subscriptions` resource
* add new methods to UserClient: `link_bank_account`, `verify_mfa`, `attach_photo_id`, `add_escrow_account`
* add `Banks` object with `list` method which returns supported banks from https://synapsepay.com/api/v3/institutions/show
* consider creating a `Response` object wrapper
* updates samples

### Tests

Run `bundle exec rake test`. To include integration tests run with `USER_ID=YOUR_USER_ID` being a user you created in sandbox.

### Releasing

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/javierjulio/synapse_payments. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
