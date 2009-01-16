require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe 'it_should_validate_present' do

  before do

    class User
      include DataMapper::Resource

      property :id,          Serial
      property :name,        String,  :auto_validation => false
      property :email,       String,  :auto_validation => false
      property :address,     String,  :auto_validation => false
      property :is_active,   Boolean, :auto_validation => false
      property :join_date,   Date,    :auto_validation => false

      validates_present :name, :when => :name_test
      validates_present :email, :is_active
      validates_present :address, :message => 'User cannot be homeless'
      validates_present :join_date
    end

    User.fix {{ 
      :name      => 'Jimmy Page',
      :email     => 'jimmy_page@fmail.com',
      :is_active => [ true, false ].pick,
      :address   => 'Hello World Avenue, Apt 989, Republic Mars',
      :join_date => Date.new
    }}

    User.auto_migrate!
    @instances = {}
  end

  after do
    Object.send(:remove_const,'User') 
  end

  def instance(id=:default)
    @instances[id] ||= User.gen
  end

  describe '{ :email }' do
    it_should_validate_present :email
  end

  describe '{ :email, :type => :String }' do
    it_should_validate_present :email, :type => :String
  end

  describe '{ :is_active, :type => :Boolean }' do
    it_should_validate_present :is_active, :type => :Boolean
  end

  describe '{ :join_date, :type => :Date }' do
    it_should_validate_present :join_date, :type => :Date
  end

  describe '{ :address, :message => "..." }' do
    it_should_validate_present :address, :message => 'User cannot be homeless'
  end

  describe '{ :name, :when => :name_test }' do
    it_should_validate_present :name, :when => :name_test
  end
  
end
