require 'chef/knife'
require 'colorize'
require 'mixlib/cli'

##
# This class represents Knife options
class KnifeCliTemplate
  include Mixlib::CLI
end

##
# This class represents Node
class Node
  attr_reader :name, :status

  def create(params)
    @name = "#{params.chef.env}-#{params.chef.role}-#{rand(36**6).to_s(36)}".tr('_', '-')
    @status = false
    args = %W(
      linode server create
      -r role[#{params.chef.role}]
      --environment #{params.chef.env}
      --linode-image #{params.linode.image}
      --linode-kernel #{params.linode.kernel}
      --linode-datacenter #{params.linode.datacenter}
      --linode-flavor #{params.linode.flavor}
      --linode-node-name #{@name}
      --node-name #{@name}
      --bootstrap-template /twiket-bootstrap
    )
    args.concat %W(--bootstrap-version #{params.chef.version}) if params.chef.version
    begin
      Chef::Knife.run args
      Chef::Knife.run %W(tag create #{@name} maintain) if params.maintain
    rescue SystemExit, StandardError => e
      puts "Catch exception of type: #{e.class}".red
      puts "Message: #{e.message}".red
      delete unless params.save
    else
      @status = true
    end
  end

  def delete(node = @name)
    puts "Destroy node: #{name}".green
    KnifeCliTemplate.option(:yes, long: '--yes')
    Chef::Knife.run %W(linode server delete #{node}), KnifeCliTemplate.options
    Chef::Knife.run %W(node delete #{node}), KnifeCliTemplate.options
  end
end
