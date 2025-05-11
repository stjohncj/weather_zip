ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "vcr"
module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    #
    VCR.configure do |config|
      config.cassette_library_dir = "test/vcr_cassettes"
      config.hook_into :faraday
      config.default_cassette_options = {
        record: :once,
        match_requests_on: [ :method, :uri ]
      }
    end
  end
end
