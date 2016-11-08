require 'chef/knife'
require 'mixlib/cli'

##
# This class represents Knife options
class KnifeCliTemplate
  include Mixlib::CLI
end

##
# This class represents chef environment
class Env
  attr_reader :name

  def create
    @name = "ci#{rand(36**3).to_s(36)}"
    KnifeCliTemplate.option(:yes, long: '--yes')
    KnifeCliTemplate.option(:disable_editing, long: '--disable-editing', boolean: true)
    Chef::Knife.run %W( environment create #{@name} --disable-editing), KnifeCliTemplate.options
  end

  def update(branch, cookbooks)
    system 'bundle exec berks install -q'
    system({ 'BERKS_TWIKET_BRANCH' => branch }, "bundle exec berks update #{cookbooks.join(' ')} -q")
    system "bundle exec berks apply #{@name} -q"
  end

  def show(env = @name)
    Chef::Knife.run %W( environment show #{env})
  end

  def delete(env = @name)
    KnifeCliTemplate.option(:yes, long: '--yes')
    Chef::Knife.run %W( environment delete #{env}), KnifeCliTemplate.options
  end
end
