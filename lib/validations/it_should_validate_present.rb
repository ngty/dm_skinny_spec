module DmSkinnySpec::Validations::ItShouldValidatePresent

  ##
  # Creates expectations for verifying that +attribute+'s value is not blank, where:
  # * for string value, blank equals '' and nil
  # * for all other types of value, blank equals nil,
  #
  # Supported options are:
  # * :type    ... the class for the attribute, default is :String
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
  #     property :id,        Serial
  #     property :name,      String,  :auto_validation => false
  #     property :email,     String,  :auto_validation => false
  #     property :address,   String,  :auto_validation => false
  #     property :is_active, Boolean, :auto_validation => false
  #   
  #     validates_present :name, :when => :name_test
  #     validates_present :email, :is_active
  #     validates_present :address, :message => 'User cannot be homeless'
  #   end
  #   
  #   User.fix {{ 
  #     :name      => 'Jimmy Page',
  #     :email     => 'jimmy_page@fmail.com',
  #     :is_active => [ true, false ].pick,
  #     :address   => 'Hello World Avenue, Apt 989, Republic Mars'
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
  #     it_should_validate_present :email
  #     it_should_validate_present :is_active, :type => :Boolean
  #     it_should_validate_present :address, :message => 'User cannot be homeless'
  #     it_should_validate_present :name, :when => :name_test
  #     
  #   end
  #
  def it_should_validate_present( attribute, options={} )
    builder = DmSkinnySpec::Validations::ItShouldValidatePresent
    builder.create_expectations_for attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def create_expectations
        case @options[:type]
          when :String, nil
            @message ||= '%s must not be blank'.t(@attribute_name)
            create_expectations_for_values [ nil, '' ]
          when :Boolean
            @message ||= '%s must not be nil'.t(@attribute_name)
            create_expectations_for_values nil
          else
            @message ||= '%s must not be blank'.t(@attribute_name)
            create_expectations_for_values nil
        end
      end

  end

end
