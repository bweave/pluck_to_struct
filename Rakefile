# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Run tests"
task :test do
  sh "bin/test"
end

desc "Rerun tests"
task :rerun do
  sh "bundle exec rerun -bcx --no-notify -- bundle exec rake test"
end

task default: %i[test]
