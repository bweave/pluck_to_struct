require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"

  # Check if ARGV contains test file path or line number
  test_file = ARGV.find { |arg| arg.start_with?('test/') }

  if test_file
    t.test_files = FileList[test_file]
    # Prevent rake from trying to run the test file path as a task
    task test_file.to_sym do; end
  else
    t.test_files = FileList["test/**/*_test.rb", "test/**/test_*.rb"]
  end
end

desc "Start an interactive console with PluckToStruct and sample data loaded"
task :console do
  exec "bin/console"
end

desc "Run RuboCop linting"
task :rubocop do
  sh "bundle exec rubocop"
end

desc "Run RuboCop with auto-correction"
task :rubocop_fix do
  sh "bundle exec rubocop --autocorrect-all"
end

task default: :test
