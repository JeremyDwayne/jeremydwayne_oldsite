set :application, 'jeremydwayne' 
set :ruby_version, "ruby-2.4.1"
set :repo_url, 'git@github.com:jeremydwayne/jeremydwayne.git'
set :user, 'deploy'

set :use_sudo, false
set :pty, true
set :repository_cache, "git_cache"
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/#{fetch(:application)}"
set :tmp_dir, "/home/#{fetch(:user)}/tmp"

set :ssh_options, { 
  forward_agent: true, 
  keys: %w(~/.ssh/id_rsa) 
}

# RVM Settings
set :rvm1_ruby_version, "#{fetch :ruby_version}@#{fetch :application}"
set :rvm1_map_bins, %w{rake gem bundle ruby}
before 'deploy', 'app:update_rvm_key'
before 'deploy', 'rvm1:install:rvm'
after 'rvm1:install:rvm', 'rvm1:install:ruby'
after 'rvm1:install:ruby', 'app:install_bundler'

namespace :app do
  task :update_rvm_key do
    on release_roles :all do
      execute :gpg, "--keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3"
    end
  end

  desc "Install Bundler"
  task :install_bundler do
    on release_roles :all do
      execute "cd #{release_path} && #{fetch(:rvm1_auto_script_path)}/rvm-auto.sh . gem install bundler"
    end
  end
end

set :puma_threads, [4, 16]
set :puma_workers, 0
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
Rake::Task["deploy:assets:precompile"].clear_actions
class PrecompileRequired < StandardError; end

set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
namespace :puma do

	desc 'Create Directories for Puma Pids and Socket'
	task :make_dirs do
		on roles(:app) do
			execute "mkdir #{shared_path}/tmp/sockets -p"
			execute "mkdir #{shared_path}/tmp/pids -p"
		end
	end

	before 'deploy:starting', 'puma:make_dirs'
end

namespace :deploy do
	namespace :assets do
		desc "Precompile assets"
		task :precompile do
			on roles(fetch(:assets_roles)) do
				within release_path do
					with rails_env: fetch(:rails_env) do
						begin
							# find the most recent release
							latest_release = capture(:ls, '-xr', releases_path).split[1]

							# precompile if this is the first deploy
							raise PrecompileRequired unless latest_release

							latest_release_path = releases_path.join(latest_release)

							# precompile if the previous deploy failed to finish precompiling
							execute(:ls, latest_release_path.join('assets_manifest_backup')) rescue raise(PrecompileRequired)

							fetch(:assets_dependencies).each do |dep|
								# execute raises if there is a diff
								execute(:diff, '-Naur', release_path.join(dep), latest_release_path.join(dep)) rescue raise(PrecompileRequired)
							end

							info("Skipping asset precompile, no asset diff found")

							# copy over all of the assets from the last release
							execute(:cp, '-r', latest_release_path.join('public', fetch(:assets_prefix)), release_path.join('public', fetch(:assets_prefix)))
						rescue PrecompileRequired
							execute(:rake, "assets:precompile") 
						end
					end
				end
			end
		end
	end


	desc "Make sure local git is in sync with remote."
	task :check_revision do
		on roles(:app) do
			unless `git rev-parse HEAD` == `git rev-parse origin/master`
				puts "WARNING: HEAD is not the same as origin/master"
				puts "Run `git push` to sync changes."
				exit
			end
		end
	end

	desc 'Initial Deploy'
	task :initial do
		on roles(:app) do
			before 'deploy:restart', 'puma:start'
			invoke 'deploy'
		end
	end

	desc 'Restart application'
	task :restart do
		on roles(:app), in: :sequence, wait: 5 do
			invoke 'puma:restart'
		end
	end

	before :starting,     :check_revision
	after  :finishing,    :compile_assets
	after  :finishing,    :cleanup
	# after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
