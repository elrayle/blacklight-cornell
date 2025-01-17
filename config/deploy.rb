$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'deploy')
require "dotenv/deployment/capistrano"
set :application, "blacklight-cornell"
set :repository,  "git@github.com:/cul-it/blacklight-cornell"
set :use_sudo, false
set :scm, :git
set :scm_verbose, true 
#set :user, "es287"
set :user, "rails"
set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-2.1.5/bin:/usr/local/rvm/gems/ruby-2.1.5@global/bin:/usr/local/rvm/rubies/ruby-2.1.5/bin:/usr/local/rvm/bin:$PATH",
  'RUBY_VERSION' => "ruby 2.1.5",
  'GEM_HOME'     => "/usr/local/rvm/gems/ruby-2.1.5",
  'GEM_PATH'     => "/usr/local/rvm/gems/ruby-2.1.5:/usr/local/rvm/gems/ruby-2.1.5@global",
#  'BUNDLE_PATH'  => "/usr/local/rvm/gems/ruby-2.1.5@global/gems/bundler-1.3.5/",  # If you are using bundler.
#  'BUNDLE_PATH'  => "/usr/local/rvm/bin/bundle"  # If you are using bundler.
}
#Deploy to may vary depending on target stage
#set :deploy_to, "/libweb/#{user}"
set :deploy_via, :copy
set :bundle_flags,    "--local --deployment "
#set :bundle_flags,    "--deployment --quiet"
#set :bundle_flags, ""    

#role  :app, "culsearchdev.library.cornell.edu"
#role  :web, "culsearchdev.library.cornell.edu"
#role  :db, "culsearchdev.library.cornell.edu", :primary => true

require 'bundler/capistrano'
require 'capistrano/ext/multistage'

set :stages, ["integration","development", "staging", "production"]
set :default_stage, "staging"
default_run_options[:pty] = true

task :cold do
  transaction do
    update
    setup_db  #replacing migrate in original
    start
  end
end

task :setup_db, :roles => :app do
  raise RuntimeError.new('db:setup aborted!') unless Capistrano::CLI.ui.ask("About to `rake db:setup`. Are you sure to wipe the entire database (anything other than 'yes' aborts):") == 'yes'
  run "cd #{current_path}; bundle exec rake db:setup RAILS_ENV=#{rails_env}"
end

task :reqmigrate, :roles => :db  do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    migrate_env = fetch(:migrate_env, "")
    migrate_target = fetch(:migrate_target, :latest)

    directory = case migrate_target.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
      end
 
    #run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} blacklight_cornell_requests:install:migrations"
    run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} blacklight_cornell_requests:install:migrations"
end

task :allmigrate, :roles => :db  do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    migrate_env = fetch(:migrate_env, "")
    migrate_target = fetch(:migrate_target, :latest)

    directory = case migrate_target.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
      end
 
    #run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} blacklight_cornell_requests:install:migrations"
    run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:migrate"
end

desc "Fix file permissions"
task :fix_file_permissions, :roles => [ :app, :db, :web ] do
	run "chmod -R g+rw #{deploy_to}"
end

desc "Install db yml generated by puppet, but add a development mode"
task :add_devdb_to_puppet_db_yml, :roles => [ :app, :db, :web ] do
	run "test -d  #{deploy_to}/shared/config/ || mkdir -p #{deploy_to}/shared/config/"
	run "cat #{deploy_to}/config/database.yml | sed -e 's/blacklight-cornell/blacklightcornell/' >  #{deploy_to}/shared/config/database.yml"
        run "sed -e s/production/development/ -e s/blacklight-cornell/blacklightcornell/  #{deploy_to}/config/database.yml >> #{deploy_to}/shared/config/database.yml"
        run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
end 

desc "Install db yml generated by puppet"
task :install_puppet_db_yml, :roles => [ :app, :db, :web ] do
	run "test -d  #{deploy_to}/shared/config/ || mkdir -p #{deploy_to}/shared/config/"
	run "cat #{deploy_to}/config/database.yml | sed -e 's/blacklight-cornell/blacklightcornell/' >  #{deploy_to}/shared/config/database.yml"
        run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
end
namespace :deploy do
    namespace :db do

       desc <<-DESC
        [internal] Updates the symlink for database.yml file to the just deployed release.
       DESC
       task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
       end
    end
end

#after "deploy:finalize_update", "deploy:db:symlink"
desc "Tailor solr config to local machine"
task :tailor_solr_yml, :roles => [ :web ] do
	run "sed -e s/da-prod-solr1.library.cornell.edu/$CAPISTRANO:HOST$/ #{deploy_to}/current/config/solr.yml >/tmp/slr.rb && sed -e s,//newcatalog,//da-prod-solr, /tmp/slr.rb  >#{deploy_to}/current/config/solr.yml"
        run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
end

desc "Copy api keys file -- too sensitive for git"
task :copy_api_keys_yml, :roles => [ :app, :db, :web ] do
	upload(ENV["HOME"] + "/blacklight-cornell/config/search_apis.yml","#{deploy_to}/shared/config/search_apis.yml")
end

desc "Install api keys file -- too sensitive for git"
task :install_api_keys_yml, :roles => [ :app, :db, :web ] do
        run "cp #{deploy_to}/config/search_apis.yml #{latest_release}/config/search_apis.yml" 
end

desc "Guarantee app signal environment -- too sensitive for git"
task :export_app_yml, :roles => [ :app, :db, :web ] do
         rails_env = fetch(:rails_env, "production")
         #run "cd  #{deploy_to}/current/ ; pwd ; export `grep APPSIGNAL_PUSH_API_KEY  .env`  ; echo $APPSIGNAL_PUSH_API_KEY ; bundle exec bin/appsignal notify_of_deploy --user=jenkins  --revision=#{ENV['GIT_COMMIT']} --environment=#{stage} --name=BlacklightCornell "
	run "cd  #{current_path} ; pwd ; export `grep APPSIGNAL_PUSH_API_KEY  .env`  ; erb config/appsignal.yml > a ; mv a config/appsignal.yml;  cat config/appsignal.yml ;  echo $APPSIGNAL_PUSH_API_KEY ; appsignal notify_of_deploy --user=jenkins  --revision=#{ENV['GIT_COMMIT']} --environment=#{stage} --name=BlacklightCornell "
end

#after :deploy, "fix_file_permissions"
#after :deploy, "install_puppet_db_yml"
after :deploy, "tailor_solr_yml"
before 'appsignal:deploy', "export_app_yml"
desc "Install  env -- too sensitive for git - production"
task :install_env, :roles => [ :app, :db, :web ] do
        run "cp #{deploy_to}/config/.env  #{shared_path}/.env"
        run "cat #{shared_path}/.env"
end
 
after "deploy:setup", "install_env"
# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

require 'appsignal/capistrano'
