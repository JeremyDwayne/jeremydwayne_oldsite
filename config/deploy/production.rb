set :stage, :production
set :branch, "master"
server 'jeremydwayne.com', user: 'deploy', roles: %w{web app db}
