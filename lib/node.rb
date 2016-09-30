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
  attr_reader :params
  attr_accessor :status

  def initialize(params)
    @params = params
    @hash = rand(36**6).to_s(36)
    @status = false
  end

  def name
    "#{params[:environment]}-#{params[:role]}-#{@hash}".tr('_', '-')
  end

  def name_colorize
    status ? name.green : name.red
  end

  def fail?
    !status
  end

  def deploy
    args = %W(
      linode server create
      --bootstrap-version #{params[:bootstrap_version]}
      -r role[#{params[:role]}]
      --linode-image #{params[:image]}
      --linode-kernel #{params[:kernel]}
      --linode-datacenter #{params[:datacenter]}
      --linode-flavor #{params[:flavor]}
      --linode-node-name #{name}
      --node-name #{name}
      --bootstrap-template templates/twiket-bootstrap)
    begin
      Chef::Knife.run args
      Chef::Knife.run %W(tag create #{name} maintain) unless @params[:no_maintain]
    rescue SystemExit, StandardError => e
      puts "Catch exception of type: #{e.class}".red
      puts "Message: #{e.message}".red
      KnifeCliTemplate.option(:yes, long: '--yes')
      unless @params[:save_nodes]
        Chef::Knife.run %W(linode server delete #{name}), KnifeCliTemplate.options
        Chef::Knife.run %W(node delete #{name}), KnifeCliTemplate.options
      end
    else
      @status = true
    end
  end
end
