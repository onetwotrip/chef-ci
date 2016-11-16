require 'chef/knife'
require 'mixlib/cli'
require 'open3'

##
# This class represents Knife options
class KnifeCliTemplate
  include Mixlib::CLI
end

##
# This class represents Node
class Node
  attr_reader :name, :status, :output
  HandleExceptions = [
    RuntimeError,
    SystemExit,
    StandardError,
  ].freeze

  def initialize(name: nil, autogen: nil)
    raise ArgumentError, 'wrong number of arguments (name: or autogen:)' unless name || autogen
    @name = (name || "#{autogen}-#{rand(36**6).to_s(36)}").tr('_', '-')
    @status = false
  end

  def create(params)
    puts "Create node: #{@name}"
    args = %W(
      knife linode server create
      -r 'role[#{params.chef.role}]'
      --environment #{params.chef.env}
      --linode-image #{params.linode.image}
      --linode-kernel #{params.linode.kernel}
      --linode-datacenter #{params.linode.datacenter}
      --linode-flavor #{params.linode.flavor}
      --linode-node-name #{@name}
      --node-name #{@name}
      --bootstrap-template /twiket-bootstrap
      --bootstrap-version #{params.chef.version}
    )
    begin
      @output = system_call args.join(' ') # Chef::Knife.run args
      Chef::Knife.run %W(tag create #{@name} maintain) if params.maintain
    rescue *HandleExceptions => e
      @output = "Catch exception of type: #{e.class}\n#{e.message}"
      @status = false
    else
      @status = true
    end
  end

  def delete
    puts "Destroy node: #{@name}"
    KnifeCliTemplate.option(:yes, long: '--yes')
    Chef::Knife.run %W(linode server delete #{@name}), KnifeCliTemplate.options
    Chef::Knife.run %W(node delete #{@name}), KnifeCliTemplate.options
  end

  private

  def with_captured_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('', 'w')
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

  def system_call(cmd)
    stdout, status = Open3.capture2e cmd
    raise stdout unless status.success?
  end
end
