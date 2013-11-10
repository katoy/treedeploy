# -*- coding: utf-8 -*-

require 'bundler/gem_tasks'
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

desc 'Delete doc/*, coverage/*, log/*, pkg/*. **/*~, **/#*'
task :clean do
  system 'rm -fr doc/*'
  system 'rm -fr coverage/*'
  system 'rm -fr log/*'
  system 'rm -fr pkg/*'
  system 'rm -f tmp/checkstyle.xml'
  Dir.glob('**/*~').each { |f| FileUtils.rm f }
  Dir.glob('**/#*').each { |f| FileUtils.rm f }
end

require 'metric_fu'

desc 'checkstyle using rubocop.'
task :checkstyle do
  system 'rubocop -r rubocop/formatter/checkstyle_formatter -R --format Rubocop::Formatter::CheckstyleFormatter --out tmp/checkstyle.xml lib spec'
end
