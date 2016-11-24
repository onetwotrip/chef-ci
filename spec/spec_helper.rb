require 'bundler/setup'
require 'simplecov'
require 'common_libs'

SimpleCov.start do
  SimpleCov.minimum_coverage_by_file 95
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
