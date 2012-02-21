require 'rubygems'
require 'minitest/unit'
require 'minitest/mock'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require File.expand_path('../../lib/director', __FILE__)
require File.expand_path('../../lib/frame', __FILE__)

ENVIRONMENT = :test

MiniTest::Unit.autorun
