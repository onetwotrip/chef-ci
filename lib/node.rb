require 'chef/knife'
require 'colorize'
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

  def create(params)
    @name = "#{params.chef.env}-#{params.chef.role}-#{rand(36**6).to_s(36)}".tr('_', '-')
    @status = false
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
      puts "Bootstrap node with cmd:\n#{args.join(' ')}"
      @output = system_call args.join(' ') # Chef::Knife.run args
      Chef::Knife.run %W(tag create #{@name} maintain) if params.maintain
    rescue SystemExit, StandardError => e
      puts "Catch exception of type: #{e.class}".red
      puts "Message: #{e.message}".red
    rescue RuntimeError => e
      @output = e.message
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
