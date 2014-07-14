require_relative 'config/boot'

require 'yaml'
require 'logger'
require 'active_record'

namespace :db do
  def migrations_path
    ENV['MIGRATIONS_DIR'] || App.paths.migrations
  end
  task :environment do
    # App registers the db connection

    App.env
  end

  # desc 'Create the database from config/database.yml for the current DATABASE_ENV'
  # task :create => :environment do
  #   ActiveRecord::Base.connection.create_database(config, options)
  # end

  desc 'Drops the database for the current DATABASE_ENV'
  task :drop => :environment do
    raise 'not implemented'
    ActiveRecord::Base.connection.drop_database(DATABASE_ENV)
  end

  desc 'Migrate the database (options: VERSION=x, VERBOSE=false).'
  task :migrate => :environment do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate(migrations_path, ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback(migrations_path, step)
  end

  desc "Retrieves the current schema version number"
  task :version => :environment do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end
end