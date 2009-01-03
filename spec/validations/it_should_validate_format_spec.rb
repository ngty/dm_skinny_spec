require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe "common format validation", :shared => true do

  before do

    ALLOW_NIL = @allow_nil

    class User
      include DataMapper::Resource

      ADDRESS_FORMAT = /\w{5,10} (st|ave), republic (moon|mars)/
      ADDRESS_PROC   = lambda { |s| s=~ADDRESS_FORMAT }

      property :id,         Serial
      property :name,       String, :auto_validation => false
      property :address,    String, :auto_validation => false
      property :email,      String, :auto_validation => false
      property :blog_url,   String, :auto_validation => false
      property :im_account, String, :auto_validation => false

      validates_format :name,     :as => /^\w{5,10}$/,   :allow_nil => ::ALLOW_NIL
      validates_format :address,  :as => ADDRESS_PROC,   :allow_nil => ::ALLOW_NIL
      validates_format :email,    :as => :email_address, :allow_nil => ::ALLOW_NIL
      validates_format :blog_url, :as => :url,           :allow_nil => ::ALLOW_NIL

      validates_format :im_account, :as => :email_address, :allow_nil => true,
        :message => "IM-Account looks fishy", :when => :im_account_test
    end

    User.fix {{ 
      :name       => /\w{5,10}/.gen,
      :email      => /\w{10}/.gen + '@fmail.com',
      :address    => User::ADDRESS_FORMAT.gen,
      :blog_url   => /http:\/\/\w{5,10}.(com|org|net)/.gen,
      :im_account => /\w{10}/.gen + '@fmail.com'
    }}

    User.auto_migrate!
    @instances = {}
  end

  after do
    Object.send( :remove_const, 'User' )
    Object.send( :remove_const, 'ALLOW_NIL' )
  end

  def instance(id=:default)
    @instances[id] ||= User.gen
  end

  def self.names
    @names_proc ||= lambda { |key| {
      :invalid => [ 'aabb', 'aabbccddeeff' ],
      :valid  => [ 'aabbcc', '112233' ]
    }[key] }
  end

  def self.addresses
    @addresses_proc ||= lambda { |key| {
      :invalid => [ 'eeffgg st, republic sun', 'aa ave, republic mars' ],
      :valid   => [ 'aabbcc st, republic moon', 'zzyyxx ave, republic mars' ]
    }[key] }
  end

end

describe "it_should_validate_format" do

  it_should_behave_like "common format validation"

  describe '{ :im_account, :as => :email_address, :message => ... }' do
    it_should_validate_format :im_account, :as => :email_address, 
      :message => 'IM-Account looks fishy', :when => :im_account_test
  end

end

describe "given allow_nil validate, it_should_validate_format" do

  before do
    @allow_nil = true
  end

  it_should_behave_like "common format validation"

  describe '{ :name, :invalids => [...], :valids => [...] }' do
    it_should_validate_format :name, 
      :valids => names[:valid], :invalids => names[:invalid]
  end

  describe '{ :address, :invalids => [...], :valids => [...] }' do
    it_should_validate_format :address, 
      :valids => addresses[:valid], :invalids => addresses[:invalid]
  end

  describe '{ :email, :as => :email_address }' do
    it_should_validate_format :email, :as => :email_address
  end

  describe '{ :email, :with => :email_address }' do
    it_should_validate_format :email, :with => :email_address
  end

  describe '{ :blog_url, :as => :url }' do
    it_should_validate_format :blog_url, :as => :url
  end

  describe '{ :blog_url, :with => :url }' do
    it_should_validate_format :blog_url, :with => :url
  end

  describe '{ :name, :invalids => [...], :valids => [...], :allow_nil => true }' do
    it_should_validate_format :name, :allow_nil => true,
      :valids => names[:valid], :invalids => names[:invalid]
  end

  describe '{ :address, :invalids => [...], :valids => [...], :allow_nil => true }' do
    it_should_validate_format :address, :allow_nil => true,
      :valids => addresses[:valid], :invalids => addresses[:invalid]
  end

  describe '{ :email, :as => :email_address, :allow_nil => true }' do
    it_should_validate_format :email, :as => :email_address, :allow_nil => true
  end

  describe '{ :blog_url, :as => :url, :allow_nil => true }' do
    it_should_validate_format :blog_url, :as => :url, :allow_nil => true
  end

end

describe "given !allow_nil validate, it_should_validate_format" do

  before do
    @allow_nil = false
  end

  it_should_behave_like 'common format validation'

  describe '{ :name, :invalids => [...], :valids => [...], :allow_nil => false }' do
    it_should_validate_format :name, :allow_nil => false,
      :valids => names[:valid], :invalids => names[:invalid]
  end

  describe '{ :address, :invalids => [...], :valids => [...], :allow_nil => false }' do
    it_should_validate_format :address, :allow_nil => false,
      :valids => addresses[:valid], :invalids => addresses[:invalid]
  end

  describe '{ :email, :as => :email_address, :allow_nil => false }' do
    it_should_validate_format :email, :as => :email_address, :allow_nil => false
  end

  describe '{ :blog_url, :as => :url, :allow_nil => false }' do
    it_should_validate_format :blog_url, :as => :url, :allow_nil => false
  end

end
