require 'bundler/capistrano'

set :application, "Entretenerse"
set :repository,  "entretenerse@173.203.29.5:/home/git/repositories/entretenerse.git"

ssh_options[:forward_agent] = true # Forward ssh keys from my local machine
default_environment['PATH'] = "$HOME/webapps/entretenerse/bin:$PATH"
default_environment['GEM_HOME'] = "$HOME/webapps/entretenerse/gems"

set :scm, :git
set :branch, "master"
set :scm_verbose, true
set :scm_username, 'git'
set :git_account, 'git'
set :deploy_via, :remote_cache
set :keep_releases, 5

role :app, "entretenerse.com.ar"
role :db,  "entretenerse.com.ar", :primary => true
set :user, "entretenerse1"  # The server's user for deploys
set :runner, "entretenerse"
set :use_sudo, false
set :deploy_to, "/home/entretenerse/webapps/entretenerse/"  #where on the server we want our application to live

after 'deploy', 'deploy:thumbnails'
after 'deploy', 'deploy:prepare'
after "deploy:update", "deploy:cleanup" # remove all but last :keep_releases number of releases

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path, 'tmp','restart.txt')}"
  end

  task :path do
    run "echo $PATH"
  end

  task :thumbnails do
    run "ln -s $HOME/webapps/entretenerse/thumbnails #{File.join(current_path, 'public', 'images', 'thumbnails')}"
  end

  task :prepare do
    run "cd #{current_path} && rake prep:do"
  end

  #desc "Migrating the database"
  #task :migrate, :roles => :app do
    #run <<-CMD
      #cd  #{release_path}; RAILS_ENV=#{stage} rake db:migrate
    #CMD
  #end
  
end
