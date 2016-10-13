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

  def name_colorize
    status ? @name.green : @name.red
  end

  def get(name)
    @name = name
  end

  def create(params)
    @name = "#{params[:environment]}-#{params[:role]}-#{rand(36**6).to_s(36)}".tr('_', '-')
    @status = false
    args = %W(
      linode server create
      --bootstrap-version #{params[:bootstrap_version]}
      -r role[#{params[:role]}]
      --linode-image #{params[:image]}
      --linode-kernel #{params[:kernel]}
      --linode-datacenter #{params[:datacenter]}
      --linode-flavor #{params[:flavor]}
      --linode-node-name #{@name}
      --node-name #{@name}
      --bootstrap-template templates/twiket-bootstrap)
    begin
      Chef::Knife.run args
      Chef::Knife.run %W(tag create #{@name} maintain) unless params[:no_maintain]
    rescue SystemExit, StandardError => e
      puts "Catch exception of type: #{e.class}".red
      puts "Message: #{e.message}".red
      delete unless params[:save_nodes]
    else
      @status = true
    end
  end

  def delete(node = @name)
    KnifeCliTemplate.option(:yes, long: '--yes')
    Chef::Knife.run %W(linode server delete #{node}), KnifeCliTemplate.options
    Chef::Knife.run %W(node delete #{node}), KnifeCliTemplate.options
  end
end
