require "bundler/setup"

ENV['RACK_ENV'] = 'test'
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rack/test'
require 'webmock/rspec'
require_relative "../lib/word_diff"

WebMock.disable_net_connect!

def fixture_dir
  File.expand_path "fixtures", File.dirname(__FILE__)
end

def fixture(name)
  File.expand_path name, fixture_dir
end
