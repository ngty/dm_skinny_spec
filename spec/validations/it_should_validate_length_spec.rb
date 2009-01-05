require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe "common length validation", :shared => true do

  before do

    ALLOW_NIL = @allow_nil

    class User
      include DataMapper::Resource

      property :id,         Serial
      property :first_name, String, :auto_validation => false
      property :last_name,  String, :auto_validation => false
      property :email,      String, :auto_validation => false
      property :address,    String, :auto_validation => false
      property :nick_name,  String, :auto_validation => false
      property :error,      String, :auto_validation => false
      property :opt_error,  String, :auto_validation => false

      validates_length :first_name, :min => 2,      :allow_nil => ::ALLOW_NIL
      validates_length :last_name,  :max => 10      #, :allow_nil => ::ALLOW_NIL
      validates_length :email,      :is  => 20,     :allow_nil => ::ALLOW_NIL
      validates_length :address,    :in  => 20..30, :allow_nil => ::ALLOW_NIL
      validates_length :error,      :is  => 0,      :allow_nil => ::ALLOW_NIL
      validates_length :opt_error,  :in  => 0..1,   :allow_nil => ::ALLOW_NIL

      validates_length :nick_name,  :max => 10,     # :allow_nil => false,
        :message => 'Nickname cannot be longer than 10 chars', :when => :nick_name_test
    end

    User.fix {{ 
      :first_name => /\w{3,10}/.gen,
      :last_name  => /\w{3,10}/.gen,
      :email      => /\w{10}/.gen + '@fmail.com',
      :address    => /\w{4,9} \w{4,9} \w{10}/.gen,
      :nick_name  => /\w{2,9}/.gen,
      :error      => ''
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

end

describe "it_should_validate_length" do

  it_should_behave_like "common length validation"

  describe '{ :nick_name, :max => 10, :when => :nick_name_test, :message => ... }' do
    it_should_validate_length :nick_name, :max => 10, 
      :when => :nick_name_test, 
      :message => 'Nickname cannot be longer than 10 chars'
  end

end

describe "(nullable attr) it_should_validate_length" do

  before do
    @allow_nil = true
  end

  it_should_behave_like "common length validation"

  describe '{ :first_name, :min => 2 }' do
    it_should_validate_length :first_name, :min => 2
  end

  describe '{ :first_name, :minimum => 2 }' do
    it_should_validate_length :first_name, :minimum => 2
  end

  describe '{ :last_name, :max => 10 }' do
    it_should_validate_length :last_name, :max => 10
  end

  describe '{ :last_name, :maximum => 10 }' do
    it_should_validate_length :last_name, :maximum => 10
  end

  describe '{ :email, :is => 20 }' do
    it_should_validate_length :email, :is => 20
  end

  describe '{ :email, :equals => 20 }' do
    it_should_validate_length :email, :equals => 20
  end

  describe '{ :error, :is => 0 }' do
    it_should_validate_length :error, :is => 0
  end

  describe '{ :error, :equals => 0 }' do
    it_should_validate_length :error, :equals => 0
  end

  describe '{ :address, :in => 20..30 }' do
    it_should_validate_length :address, :in => 20..30
  end

  describe '{ :address, :within => 20..30 }' do
    it_should_validate_length :address, :within => 20..30
  end

  describe '{ :opt_error, :in => 0..1 }' do
    it_should_validate_length :opt_error, :in => 0..1
  end

  describe '{ :opt_error, :within => 0..1 }' do
    it_should_validate_length :opt_error, :in => 0..1
  end

  describe ':first_name, :min => 2, :allow_nil => true' do
    it_should_validate_length :first_name, :min => 2, :allow_nil => true
  end

  describe ':last_name, :max => 10, :allow_nil => true' do
    it_should_validate_length :last_name, :max => 10, :allow_nil => true
  end

  describe ':email, :is => 20, :allow_nil => true' do
    it_should_validate_length :email, :is => 20, :allow_nil => true
  end

  describe ':error, :is => 0, :allow_nil => true' do
    it_should_validate_length :error, :is => 0, :allow_nil => true
  end

  describe ':address, :in => 20..30, :allow_nil => true' do
    it_should_validate_length :address, :in => 20..30, :allow_nil => true
  end

  describe ':opt_error, :in => 0..1, :allow_nil => true' do
    it_should_validate_length :opt_error, :in => 0..1, :allow_nil => true
  end

end

describe "(non-nullable attr) it_should_validate_length" do

  before do
    @allow_nil = false
  end

  it_should_behave_like 'common length validation'

  describe '{ :first_name, :min => 2, :allow_nil => false }' do
    it_should_validate_length :first_name, :min => 2, :allow_nil => false
  end

  describe '{ :last_name, :max => 10, :allow_nil => false }' do
    it_should_validate_length :last_name, :max => 10, :allow_nil => false
  end

  describe '{ :email, :is => 20, :allow_nil => false }' do
    it_should_validate_length :email, :is => 20, :allow_nil => false
  end

  describe '{ :error, :is => 0, :allow_nil => false }' do
    it_should_validate_length :error, :is => 0, :allow_nil => false
  end

  describe '{ :address, :in => 20..30, :allow_nil => false }' do
    it_should_validate_length :address, :in => 20..30, :allow_nil => false
  end

  describe '{ :opt_error, :in => 0..1, :allow_nil => false }' do
    it_should_validate_length :opt_error, :in => 0..1, :allow_nil => false
  end

end
