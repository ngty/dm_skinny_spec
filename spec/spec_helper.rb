require 'pathname'
require 'rubygems'

gem 'rspec', '~>1.1.11'
gem 'dm-validations', '~>0.9.8'
gem 'dm-sweatshop', '~>0.9.8'
gem 'english', '~>0.3.1'

require 'spec'
require 'dm-sweatshop'
require 'dm-validations'
require 'english/style_orm'

def load_driver(name, default_uri)
  return false if ENV['ADAPTER'] != name.to_s
  begin
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]
    true
  rescue LoadError => e
    warn "Could not load do_#{name}: #{e}"
    false
  end
end

ENV['ADAPTER'] ||= 'sqlite3'
HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'dm_skinny_spec'
