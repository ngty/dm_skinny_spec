require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

class User
  include DataMapper::Resource

  property :id,          Serial
  property :name,        String,  :auto_validation => false
  property :email,       String,  :auto_validation => false
  property :address,     String,  :auto_validation => false
  property :is_active,   Boolean, :auto_validation => false

  validates_present :name, :when => :name_test
  validates_present :email, :is_active
  validates_present :address, :message => 'User cannot be homeless'
end

User.fix {{ 
  :name      => 'Jimmy Page',
  :email     => 'jimmy_page@fmail.com',
  :is_active => [ true, false ].pick,
  :address   => 'Hello World Avenue, Apt 989, Republic Mars'
}}

describe 'it_should_validate_present' do

  before do
    User.auto_migrate!
    @instances = {}
  end

  def instance(id=:default)
    @instances[id] ||= User.gen
  end

  describe '{ :email }' do
    it_should_validate_present :email
  end

  describe '{ :is_active, :boolean => true }' do
    it_should_validate_present :is_active, :boolean => true
  end

  describe '{ :address, :message => "..." }' do
    it_should_validate_present :address, :message => 'User cannot be homeless'
  end

  describe '{ :name, :when => :name_test }' do
    it_should_validate_present :name, :when => :name_test
  end
  
end
