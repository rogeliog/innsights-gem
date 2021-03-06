require 'rubygems'
require 'rspec'
require 'bundler/setup'
require 'active_record'
require 'active_support'
require 'vcr'
require 'innsights'

require File.join(File.dirname(__FILE__), 'support', 'ar')

VCR.config do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.stub_with :webmock # or :fakeweb
end


RSpec.configure do |config|

end

def json_fixture(filename)
  File.open(File.join(File.dirname(__FILE__), 'fixtures/json', filename))
end