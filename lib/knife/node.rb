require 'chef/knife'
require 'knife_fabric'

##
# This class represents Node
class Node < KnifeFabric
  attr_reader   :output
  attr_accessor :name, :role, :env,
                :chef_version,
                :image, :kernel

  def initialize(name: nil, autogen: nil)
    @name = gen_name(name, autogen)
    @status = false
    @kernel = 138
    @datacenter = 7
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
    JSON.parse system_call("knife node show #{@name} -F json -l")
  rescue RuntimeError
    {}
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

  def gen_name(name, autogen)
    hostname = if name
                 name
               elsif autogen.to_s.include? '*'
                 autogen.gsub '*', (Array('a'..'z') + Array(0..9)).sample(6).join
               elsif !autogen.to_s.include? '*'
                 raise ArgumentError, 'autogen: not contains required symbol *'
               else
                 raise ArgumentError, 'wrong number of arguments (name: or autogen:)'
               end
    check_hostname hostname.tr!('_', '-')
  end

  def check_hostname(hostname)
    raise ArgumentError, "incorrect hostname #{hostname}" unless hostname =~ /^([A-Za-z0-9\-]){6,64}$/
    hostname
  end
end