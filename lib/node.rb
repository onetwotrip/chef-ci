require 'chef/knife'
require 'open3'

##
# This class represents Node
class Node
  load 'knife_cli_template.rb'
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
    salt = (Array('a'..'z') + Array(0..9)).sample(6).join
    @name = name ? name.tr('_', '-') : "#{autogen}-#{salt}".tr('_', '-')
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
    rescue_knife do
      puts 'Bootstrap with following command:'
      puts args.join(' ')
      @output = system_call args.join(' ') # Chef::Knife.run args
      Chef::Knife.run %W(tag create #{@name} maintain) if maintain
    end
  end

  def show
    begin
      JSON.parse system_call("knife node show #{@name} -F json -l")
    rescue RuntimeError
      {}
    end
  end

  def get
    node_attr = show
    attrs = {}
    unless node_attr.empty?
      attrs[:role] = node_attr['run_list'].first.match(/role\[([\w-]+)\]/)[1]
      attrs[:env] = node_attr['chef_environment']
      attrs[:chef_version] = node_attr['automatic']['chef_packages']['chef']['version']
      attrs[:image] = node_attr['automatic']['platform_version'].eql?('14.04') ? 124 : 146
    end
    attrs
  end

  def set(params)
    @role         = params[:role]
    @env          = params[:env]
    @chef_version = params[:chef_version]
    @image        = params[:image]
  end

  def delete
    puts "Destroy node: #{@name}"
    rescue_knife { Chef::Knife.run %W(linode server delete #{@name}), KnifeCliTemplate.options }
    rescue_knife { Chef::Knife.run %W(node delete #{@name} --yes), KnifeCliTemplate.options }
    rescue_knife { Chef::Knife.run %W(client delete #{@name} --yes), KnifeCliTemplate.options }
  end

  private

  def system_call(cmd)
    stdout, status = Open3.capture2e cmd
    raise stdout unless status.success?
    stdout
  end

  def rescue_knife(&block)
    begin
      yield(block)
    rescue *HandleExceptions => e
      @output = "Catch exception of type: #{e.class}\n#{e.message}"
      @status = false
    else
      @status = true
    end
  end
end
