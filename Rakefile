require 'rake'
require 'rake/testtask'
require 'rdoc/task'

desc 'Default: run unit tests.'
task :default => :test

desc 'Run unit tests.'
Rake::TestTask.new :test do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
