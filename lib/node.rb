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
  attr_reader :status, :output
  attr_accessor :name, :role, :env,
                :chef_version,
                :image, :kernel

  HandleExceptions = [RuntimeError, SystemExit, StandardError].freeze

  def initialize(name: nil, autogen: nil)
    raise ArgumentError, 'wrong number of arguments (name: or autogen:)' unless name || autogen
    @status = false
    @kernel = 138
    @datacenter = 7
    if name
      @name = name.tr('_', '-')
      node_attr = show
      unless node_attr.empty?
        @role = node_attr['run_list'].first.match(/role\[([\w-]+)\]/)[1]
        @env = node_attr['chef_environment']
        @chef_version = node_attr['automatic']['chef_packages']['chef']['version']
        @image = node_attr['automatic']['platform_version'].eql?('14.04') ? 124 : 146
      end
    else
      salt = (Array('a'..'z') + Array(0..9)).sample(6).join
      @name = "#{autogen}-#{salt}".tr('_', '-')
    end
  end

  def create(flavor:, template:, maintain: false, datacenter: @datacenter)
    puts "Create node: #{@name}"
    args = %W(
      knife linode server create
      -r 'role[#{@role}]'
      --environment #{@env}
      --linode-image #{@image}
      --linode-kernel #{@kernel}
      --linode-datacenter #{datacenter}
      --linode-flavor #{flavor}
      --linode-node-name #{@name}
      --node-name #{@name}
      --bootstrap-template #{template}
      --bootstrap-version #{@chef_version}
    )
    begin
      puts 'Bootstrap with following command:'
      puts args.join(' ')
      @output = system_call args.join(' ') # Chef::Knife.run args
      Chef::Knife.run %W(tag create #{@name} maintain) if maintain
    rescue *HandleExceptions => e
      @output = "Catch exception of type: #{e.class}\n#{e.message}"
      @status = false
    else
      @status = true
    end
  end

  def show
    begin
      JSON.parse system_call("knife node show #{@name} -F json -l")
    rescue RuntimeError
      {}
    end
  end

  def delete
    puts "Destroy node: #{@name}"
    KnifeCliTemplate.option(:yes, long: '--yes')
    Chef::Knife.run %W(linode server delete #{@name}), KnifeCliTemplate.options
    Chef::Knife.run %W(node delete #{@name}), KnifeCliTemplate.options
    Chef::Knife.run %W(client delete #{@name}), KnifeCliTemplate.options
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
    stdout
  end
end
