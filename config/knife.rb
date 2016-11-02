log_level        :info
log_location     STDOUT
node_name        ENV['CHEF_APIUSER']
client_key       ENV['CHEF_APIKEY']
chef_server_url  ENV['CHEF_URL']
knife[:linode_api_key] = ENV['LINODE_APIKEY']
knife[:editor] = 'vim'
knife[:yes]    = ''
