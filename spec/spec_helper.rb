
require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

Dir[File.join(File.dirname(__FILE__), "..", "*.rb")].each do |f|
  require f
end

require 'rubygems'
require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect    # disables `should`
  end
end
