require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe "it_should_validate_is_accepted" do

  before do

    class Agreement

      include DataMapper::Resource

      DEFAULT_TRUES = [ '1', 1, 'true', true, 't' ]

      property :id,           Serial
      property :license,      String, :auto_validation => false
      property :terms,        String, :auto_validation => false
      property :more_terms,   String, :auto_validation => false
      property :more_license, String, :auto_validation => false

      validates_is_accepted :terms,        :allow_nil => true
      validates_is_accepted :more_license, :allow_nil => false
      validates_is_accepted :more_terms,   :accept    => [ '1', 1 ]
      validates_is_accepted :license,      :message   => 'We hate software pirates'
    end

    Agreement.fix {{ 
      :terms         => Agreement::DEFAULT_TRUES.pick,
      :license       => Agreement::DEFAULT_TRUES.pick,
      :more_license  => Agreement::DEFAULT_TRUES.pick,
      :more_terms    => [ '1', 1 ].pick
    }}

    Agreement.auto_migrate!
    @instances = {}
  end

  after do
    Object.send( :remove_const, 'Agreement' )
  end

  def instance(id=:default)
    @instances[id] ||= Agreement.gen
  end

  describe '{ :more_terms, :reject => [...] }' do
    it_should_validate_is_accepted :more_terms, 
      :reject => [ '0', 0, 'true', true, 't', 'false', false, 'f' ]
  end

  describe '{ :license, :message => ... }' do
    it_should_validate_is_accepted :license, 
      :message => 'We hate software pirates'
  end

  describe '{ :terms }' do
    it_should_validate_is_accepted :terms
  end

  describe '{ :terms, :allow_nil => true }' do
    it_should_validate_is_accepted :terms, :allow_nil => true
  end

  describe '{ :more_license, :allow_nil => false }' do
    it_should_validate_is_accepted :more_license, :allow_nil => false
  end

end
