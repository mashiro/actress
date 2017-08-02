require 'bundler'
Bundler.setup

namespace :db do
  task :load_config do
    require_relative 'app'
  end

  desc 'Migrate the database'
  task :migrate do
    sh %(bundle exec ridgepole -c config/database.yml -a --enable-mysql-awesome), verbose: false
  end

  namespace :user do
    desc 'Generate act db user create sql'
    task :create_sql do
      users = {
        'act' => 'ALL',
        'act-client' => 'SELECT, INSERT'
      }

      users.each do |user, priv|
        pass = SecureRandom.hex
        puts %(GRANT #{priv} ON act.* TO '#{user}' IDENTIFIED BY '#{pass}')
      end
    end
  end

  def root_dir
    require 'pathname'
    Pathname.new File.expand_path('../', __FILE__)
  end
end
