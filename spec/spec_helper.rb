# -*- coding: utf-8 -*-

require 'simplecov'
require 'coveralls'
require 'simplecov-rcov'

Coveralls.wear!

# simplecov, rcov, coderails の３通りの書式のレポートを生成する。
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start


SimpleCov.start do
  add_filter 'spec'
end


Dir[File.join(File.dirname(__FILE__), "..",  "lib", "treedeploy", "*.rb")].each do |f|
  require f
end

require 'rubygems'
require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect    # disables `should`
  end
end
