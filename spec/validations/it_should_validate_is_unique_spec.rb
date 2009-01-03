require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe 'it_should_validate_is_unique' do

  before do
   
    class User
      include DataMapper::Resource

      property :id,      Serial
      property :name,    String,  :auto_validation => false
      property :email,   String,  :auto_validation => false
      property :address, String,  :auto_validation => false

      validates_is_unique :name, :when => :name_test
      validates_is_unique :email
      validates_is_unique :address, :message => 'Two users cannot share the same home'
    end

    User.fix {{ 
      :name    => ( name = /\w{5,10} \w{5,10}/.gen.titlecase ),
      :email   => name.snakecase.sub(/\s+/,'_') + '@fmail.com',
      :address => /\w{5,10} (Street|Avenue), Republic (Mars|Jupiter)/.gen
    }}

    User.auto_migrate!
    @instances = {}
  end

  after do
    Object.send( :remove_const, 'User' )
  end

  def instance(id=:default)
    @instances[id] ||= User.gen
  end

  describe ':email' do
    it_should_validate_is_unique :email
  end

  describe ':address, :message => "..."' do
    it_should_validate_is_unique :address, :message => 'Two users cannot share the same home'
  end

  describe ':name, :when => :name_test' do
    it_should_validate_is_unique :name, :when => :name_test
  end
  
end
