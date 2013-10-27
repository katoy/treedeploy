require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

# yard settings
require 'yard'
require 'yard/rake/yardoc_task'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = []
  t.options << '--debug' << '--verbose' if $trace
end

desc "Delete doc/*, coverage/*, log/*, pkg/*. **/*~, **/#*"
task :clean do
  system("rm -fr doc/*")
  system("rm -fr coverage/*")
  system("rm -fr log/*")
  system("rm -fr pkg/*")
  Dir.glob("**/*~").each { |f| FileUtils.rm f }
  Dir.glob("**/#*").each { |f| FileUtils.rm f }
end

