require 'pathname'
APP_PATH = File.expand_path('../../', Pathname.new(__FILE__).realpath)
LOG_PATH = "#{APP_PATH}/logs".freeze
GEM_FILE = "#{APP_PATH}/Gemfile".freeze
BOOTSTRAP_TEMPLATE = "#{APP_PATH}/templates/twiket-bootstrap".freeze
ENV['BUNDLE_GEMFILE'] ||= GEM_FILE
require 'bundler/setup'

require 'chef/config'
require 'chef/knife'
require 'colorize'
require 'fileutils'
require 'mixlib/cli'
require 'simple_config'

require 'common/logger'

require 'knife/cookbooks'
require 'knife/env'
require 'knife/node'
