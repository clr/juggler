require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

ENVIRONMENT = :live
require File.expand_path('../lib/director', __FILE__)
require File.expand_path('../lib/frame', __FILE__)
require File.expand_path('../lib/node', __FILE__)

namespace :riak do
  task :restart_frame do
    Director.new.restart!
    puts "We are back at the beginning."
  end

  task :next do
    Director.new.run_next!
  end

  task :rewind do
    Director.new.rewind!
  end

  task :where_am_i do
    puts Director.new.get_current_frame.sub('.txt','').gsub('_',' ').upcase
  end

  namespace :cluster do
    task :create do
      Node.new.create_cluster!
    end

    task :destroy_all do
      Node.new.destroy_all_cluster!
    end

    task :start do
      Node.new.start_cluster!
    end

    task :restart do
      Node.new.restart_cluster!
    end

    task :stop do
      Node.new.stop_cluster!
    end

    task :join do
      Node.new.join_cluster!
    end

    task :status do
      Node.new.status_cluster!
    end
  end
end
