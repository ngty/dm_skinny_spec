module DmSkinnySpec::Validations::ItShouldValidateIsUnique

  ##
  # Creates expectations for verifying that +attribute+ is unique.
  #
  # Supported options are:
  # * :confirm ... the confirmation attribute to use, default is "#{attribute}_confirmation"
  # * :allow_nil ... whether nil value may be accepted, default is true
  # * :message ... customize the expected error message (optional)
  # * :when    ... context in which the validation applies (optional)
  # 
  # Notes:
  # * you have to provide an instance() method in your specs to return valid
  #   instances of your model (see the example below).
  # 
  # Examples:
  #
  #   class User
  #     include DataMapper::Resource
  #   
  #     property :id,      Serial
  #     property :name,    String,  :auto_validation => false
  #     property :email,   String,  :auto_validation => false
  #     property :address, String,  :auto_validation => false
  #   
  #     validates_is_unique :name, :when => :name_test
  #     validates_is_unique :email
  #     validates_is_unique :address, :message => 'Two users cannot share the same home'
  #   end
  #   
  #   User.fix {{ 
  #     :name    => ( name = /\w{5,10} \w{5,10}/.gen.titlecase ),
  #     :email   => name.snakecase.sub(/\s+/,'_') + '@fmail.com',
  #     :address => /\w{5,10} (Street|Avenue), Republic (Mars|Jupiter)/.gen
  #   }}
  #   
  #   describe User do
  #   
  #     before do
  #       User.auto_migrate!
  #       @instances = {}
  #     end
  #   
  #     def instance(id=:default)
  #       @instances[id] ||= User.gen
  #     end
  #   
  #     it_should_validate_is_unique :email
  #     it_should_validate_is_unique :address, :message => 'Two users cannot share the same home'
  #     it_should_validate_is_unique :name, :when => :name_test
  #     
  #   end
  #
  def it_should_validate_is_unique( attribute, options={} )
    builder = DmSkinnySpec::Validations::ItShouldValidateIsUnique
    builder.create_expectations_for attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def create_expectations
        @message ||= '%s is already taken'.t(@attribute_name)
        attribute = @attribute

        value_proc = lambda do |example| 
          example.instance(:other).attribute_get(attribute) 
        end

        create_expectations_for_values value_proc, :description => 'is not unique'
      end
  end

end
