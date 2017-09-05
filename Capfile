# Load DSL and Setup Up Stages
require 'capistrano/setup'
require 'capistrano/deploy'

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require "rvm1/capistrano3"
require 'capistrano/rails'
require 'capistrano/figaro_yml'

require 'sshkit/sudo'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
