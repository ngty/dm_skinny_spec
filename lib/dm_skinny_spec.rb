$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'

gem 'rspec',  '>=1.1.11'
gem 'extlib', '>=0.9.9'

require 'spec'
require 'extlib'

require 'dm_skinny_spec/version'
require 'validations'
