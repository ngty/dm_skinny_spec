require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe 'it_should_validate_absent' do

  before do
   
    class Page
      include DataMapper::Resource

      property :id,              Serial
      property :first_unwanted,  String,  :auto_validation => false
      property :second_unwanted, String,  :auto_validation => false
      property :is_unwanted,     Boolean, :auto_validation => false

      validates_absent :first_unwanted,  :when    => :first_unwanted_test
      validates_absent :second_unwanted, :message => "We don't want 2nd unwanted"
      validates_absent :is_unwanted   
    end

    Page.fix {{ 
      :first_unwanted  => [ nil, '' ].pick,
      :second_unwanted => [ nil, '' ].pick,
      :is_unwanted     => [ nil, false ].pick
    }}

    Page.auto_migrate!
    @instances = {}
  end

  after do
    Object.send( :remove_const, 'Page' )
  end

  def instance(id=:default)
    @instances[id] ||= Page.gen
  end

  describe ':first_unwanted, :when => :first_unwanted_test' do
    it_should_validate_absent :first_unwanted, :when => :first_unwanted_test
  end
  
  describe ':second_unwanted' do
    it_should_validate_absent :second_unwanted, :message => "We don't want 2nd unwanted"
  end

  describe ':is_unwanted, :boolean => true' do
    it_should_validate_absent :is_unwanted, :boolean => true
  end

end
