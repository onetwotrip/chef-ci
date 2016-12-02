source 'https://rubygems.org'
gem 'knife-linode', git: 'https://github.com/onetwotrip/knife-linode.git'
gem 'chef'
gem 'colorize'
gem 'SimpleConfig', git: 'https://github.com/onetwotrip/SimpleConfig'
gem 'berkshelf'
gem 'sourcify'
gem 'parallel'

group :development do
  gem 'overcommit'
end
group :test, :development do
  gem 'rake'
  gem 'rspec'
  gem 'rubocop'
end
group :test do
  gem 'simplecov'
  gem 'codeclimate-test-reporter'
end

# Specify your gem's dependencies in jira.gemspec
gemspec
