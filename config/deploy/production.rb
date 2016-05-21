set :stage, :production
server '162.248.96.45', user: 'deploy', roles: %w{web app db}
