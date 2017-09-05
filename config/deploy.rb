set :application, 'jeremydwayne' 
set :ruby_version, "ruby-2.4.1"
set :rvm_ruby_version, "ruby-2.4.1"
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

set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
Rake::Task["deploy:assets:precompile"].clear_actions
class PrecompileRequired < StandardError; end

namespace :figaro do
  desc "SCP transfer figaro configuration to the shared folder"
  task :setup do
    on roles(:app) do
      upload! "config/application.yml", "#{shared_path}/application.yml"
    end
  end

  desc "Symlink application.yml to the release path"
  task :symlink do
    on roles(:app) do
      execute "ln -sf #{shared_path}/application.yml #{release_path}/config/application.yml"
    end
  end

  desc "Check if figaro configuration file exists on the server"
  task :check do
    on roles(:app) do
      begin
        execute "test -f #{shared_path}/application.yml"
      rescue Capistrano::CommandError
        unless fetch(:force, false)
          logger.important 'application.yml file does not exist on the server "shared/application.yml"'
          exit
        end
      end
    end
  end
end
after "deploy:starting", "figaro:setup"
# after "deploy:updated", "figaro:symlink"

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
			invoke 'deploy'
		end
	end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "touch #{current_path}/tmp/restart.txt"
    end
  end

	before :starting,     :check_revision
	after  :finishing,    :compile_assets
	after  :finishing,    :cleanup
  after  :finishing,    :restart
end
