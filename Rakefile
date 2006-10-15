require 'rubygems'
require 'rake/rdoctask'
require 'rake/testtask'



desc 'Default: run unit tests.'
task :default => :test



desc 'Run unit test..'
Rake::TestTask.new(:test) do |t|
    t.libs << 'lib'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
end



desc 'Generate RDoc documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = 'Texier'
    rdoc.options << '--inline-source'
    # rdoc.rdoc_files.include('README', 'CHANGELOG')
    rdoc.rdoc_files.include('lib/**/*.rb')
end
