set :application, "blacklight-cornell"
set :repository,  "git@git.library.cornell.edu:/blacklight-cornell"
set :scm, :git
set :user, "jac244"
require 'capistrano/ext/multistage'
set :stages, ["staging", "production"]
set :default_stage, "staging"

default_run_options[:pty] = true

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
