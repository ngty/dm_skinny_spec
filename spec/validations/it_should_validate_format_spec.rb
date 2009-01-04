require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe "it_should_validate_format" do

  before do

    class User
      include DataMapper::Resource

      ADDRESS_FORMAT = /\w{5,10} (st|ave), republic (moon|mars)/
      ADDRESS_FORMAT_PROC = lambda { |s| s=~ADDRESS_FORMAT }

      property :id,         Serial
      property :name,       String, :auto_validation => false
      property :address,    String, :auto_validation => false
      property :email,      String, :auto_validation => false
      property :blog_url,   String, :auto_validation => false

      validates_format :name,  :as => /^\w{5,10}$/,   :allow_nil => true
      validates_format :email, :as => :email_address, :allow_nil => false

      validates_format :address, :as => ADDRESS_FORMAT_PROC, :allow_nil => true,
        :when => :address_test

      validates_format :blog_url, :as => :url, :allow_nil => true,
        :message => "Blog URL looks fishy"
    end

    User.fix {{ 
      :name       => /\w{5,10}/.gen,
      :email      => /\w{10}/.gen + '@fmail.com',
      :address    => User::ADDRESS_FORMAT.gen,
      :blog_url   => /http:\/\/\w{5,10}.(com|org|net)/.gen
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

  def self.invalids
    @invalid_proc ||= lambda { |key| {
      :address => [ 'eeffgg st, republic sun', 'aa ave, republic mars' ],
      :name    => [ 'aabb', 'aabbccddeeff' ]
    }[key] }
  end

  describe '{ :name, :reject => [...] }' do
    it_should_validate_format :name, :reject => invalids[:name]
  end

  describe '{ :name, :reject => [...], :allow_nil => true }' do
    it_should_validate_format :name, :reject => invalids[:name], :allow_nil => true
  end

  describe '{ :address, :reject => [...], :when => :address_test }' do
    it_should_validate_format :address, :reject => invalids[:address], 
      :when => :address_test
  end

  describe '{ :email, :as => :email_address, :allow_nil => false }' do
    it_should_validate_format :email, :as => :email_address, :allow_nil => false
  end

  describe '{ :blog_url, :as => :url, :message => ... }' do
    it_should_validate_format :blog_url, :as => :url, :message => "Blog URL looks fishy"
  end

  describe '{ :blog_url, :with => :url, :message => ... }' do
    it_should_validate_format :blog_url, :with => :url, :message => "Blog URL looks fishy"
  end

end
