require 'rubygems'
require 'bundler/setup'
require 'cover_me'
require File.join(File.dirname(__FILE__), '../lib/scribd-carrierwave.rb')
require 'mocha'


RSpec.configure do |config|
  config.mock_with :mocha
end

CoverMe.config do |c|
    c.project.root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    c.file_pattern = [
          /(#{c.project.root}.+\.rb)/i
        ]
end