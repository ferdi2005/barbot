# config valid for current version and patch releases of Capistrano
set :application, "rssbot-barbot"

server 'c.ferdi.cc', port: 22, roles: [:web, :app, :db], primary: true
set :repo_url, "git@github.com:ferdi2005/barbot.git"
set :sidekiq_service_unit_name, "#{fetch(:application)}-sidekiq"

set :user, 'deploy'
set :puma_threads,    [4, 16]
set :puma_workers,    0
set :branch, "main"

set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_phased_restart, true
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :default_env, {"LD_PRELOAD" => "/usr/lib/x86_64-linux-gnu/libjemalloc.so.2"}
set :sidekiq_user, fetch(:user)
set :sidekiq_service_unit_user, :system

append :linked_files, ".env"
append :linked_dirs, "log", "tmp/pids", "tmp/sockets", "tmp/cache", "public/uploads", "storage"

namespace :rails do
    desc 'Open a rails console `cap [staging] rails:console [server_index default: 0]`'
    task :console do
      server = roles(:app)[ARGV[2].to_i]

      puts "Opening a console on: #{server.hostname}...."

      cmd = "ssh #{fetch(:user)}@#{server.hostname} -t 'cd #{fetch(:deploy_to)}/current && RAILS_ENV=#{fetch(:rails_env)} bundle exec rails console'"

      puts cmd

      exec cmd
    end
end

namespace :deploy do
    namespace :check do
      before :linked_files, :set_master_key do
        on roles(:app), in: :sequence, wait: 10 do
            puts "Uploading .env file..."
            upload! '.env', "#{shared_path}/.env"
        end
      end
    end
end


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
