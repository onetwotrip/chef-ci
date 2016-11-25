# Cookbooks utils
class Cookbooks
  # :nocov:
  def self.get_changes(url, commit)
    system 'git init'
    system 'git rev-parse --is-inside-work-tree'
    system "git config remote.origin.url #{url}"
    system 'git -c core.askpass=true fetch --tags --progress git@gitlab.twiket.com:chef/chef.git \
            +refs/heads/*:refs/remotes/origin/*'
    system "git checkout -f #{commit}"
    `git diff --name-only origin/develop`.split(/\n/).grep(%r{cookbooks/(.*)/}).map { |f| f.match(%r{cookbooks/([\w-]+)/})[1] }.uniq
  end
  # :nocov:
end
