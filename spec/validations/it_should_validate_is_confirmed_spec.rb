require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe 'it_should_validate_is_confirmed' do

  before do
   
    class User
      include DataMapper::Resource

      property :id,                Serial
      property :password,          String, :auto_validation => false
      property :email,             String, :auto_validation => false
      property :security_question, String, :auto_validation => false

      attr_accessor :password_confirmation
      attr_accessor :security_question_confirmation
      attr_accessor :email_repeated

      validates_is_confirmed :password, :when    => :password_test,  :allow_nil => true
      validates_is_confirmed :email,    :confirm => :email_repeated, :allow_nil => false

      validates_is_confirmed :security_question, :allow_nil => true,
        :message => "We love to repeat everything, even the security question"
    end

    User.fix {{ 
      :email                          => ( email = 'jimmy@fmail.com' ),
      :password                       => ( password = 'xxyyzz' ),
      :security_question              => ( question = 'R u Happy?' ),
      :email_repeated                 => email,
      :password_confirmation          => password,
      :security_question_confirmation => question,
    }}

    User.auto_migrate!
    @instances = {}
  end

  def instance(id=:default)
    @instances[id] ||= User.gen
  end

  after do
    Object.send( :remove_const, 'User' )
  end

  describe '{ :password, :when => :password_test }' do
    it_should_validate_is_confirmed :password, :when => :password_test
  end
  
  describe '{ :password, :when => :password_test, :allow_nil => true }' do
    it_should_validate_is_confirmed :password, :when => :password_test, :allow_nil => true
  end
  
  describe '{ :email, :confirm => :email_repeated, :allow_nil => false }' do
    it_should_validate_is_confirmed :email, :confirm => :email_repeated, :allow_nil => false
  end

  describe '{ :security_question, :message => ... }' do
    it_should_validate_is_confirmed :security_question, 
      :message => "We love to repeat everything, even the security question"
  end

end
