require 'chef/knife'
require 'knife_fabric'

##
# This class represents chef environment
class Env < KnifeFabric
  attr_reader :name

  def create
    @name = "ci#{rand(36**3).to_s(36)}"
    Chef::Knife.run %W(environment create #{@name} --disable-editing --yes), KnifeCliTemplate.options
  end

  def update(branch, cookbooks)
    system 'bundle exec berks install -q'
    system({ 'BERKS_TWIKET_BRANCH' => branch }, "bundle exec berks update #{cookbooks.join(' ')} -q")
    system "bundle exec berks apply #{@name} -q"
  end

  def show(env = @name)
    Chef::Knife.run %W(environment show #{env})
  end

  def delete(env = @name)
    Chef::Knife.run %W(environment delete #{env} --yes), KnifeCliTemplate.options
  end
end
