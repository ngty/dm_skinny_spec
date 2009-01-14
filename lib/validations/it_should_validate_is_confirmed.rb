module DmSkinnySpec::Validations::ItShouldValidateIsConfirmed


  ##
  # Creates expectations for verifying that +attribute+ is confirmed by another attribute.
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
  #     property :id,                Serial
  #     property :password,          String, :auto_validation => false
  #     property :email,             String, :auto_validation => false
  #     property :security_question, String, :auto_validation => false
  #   
  #     attr_accessor :password_confirmation
  #     attr_accessor :security_question_confirmation
  #     attr_accessor :email_repeated
  #   
  #     validates_is_confirmed :password, :when    => :password_test,  :allow_nil => true
  #     validates_is_confirmed :email,    :confirm => :email_repeated, :allow_nil => false
  #     validates_is_confirmed :security_question, :allow_nil => true,
  #       :message => "We love to repeat everything, even the security question"
  #   end
  #   
  #   User.fix {{ 
  #     :email                          => ( email = 'jimmy@fmail.com' ),
  #     :password                       => ( password = 'xxyyzz' ),
  #     :security_question              => ( question = 'R u Happy?' ),
  #     :email_repeated                 => email,
  #     :password_confirmation          => password,
  #     :security_question_confirmation => question,
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
  #     it_should_validate_is_confirmed :password, :when => :password_test
  #     it_should_validate_is_confirmed :password, :when => :password_test, :allow_nil => true
  #     it_should_validate_is_confirmed :email, :confirm => :email_repeated, :allow_nil => false
  #     it_should_validate_is_confirmed :security_question, 
  #       :message => "We love to repeat everything, even the security question"
  #   
  #   end
  #
  def it_should_validate_is_confirmed( attribute, options={} )
    builder = DmSkinnySpec::Validations::ItShouldValidateIsConfirmed
    builder.create_expectations_for attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def create_expectations
        @message ||= '%s does not match the confirmation'.t(@attribute_name)
        @confirm = @options[:confirm] || "#{@attribute}_confirmation".to_sym
        confirm, attribute = @confirm, @attribute

        value_proc = lambda { |instance,i|
          '%s.%s'.t( (@orig_ok_value||=instance.attribute_get(attribute)), i )
        }

        create_expectations_for_values value_proc, :type => :ok, :description => 'matches confirmation'
        create_expectations_for_values value_proc, :description => 'does not match confirmation'
        create_expectations_for_values nil, :type => @allow_nil ? :ok : :error
      end

      def create_expectation_for_ok_value(value)
        confirm, context, attribute = @confirm, @context, @attribute
        description = "should be valid if :%s %s".t( attribute, humanize_condition(value) )

        expect description do
          ok_val = value.is_a?(Proc) ? value : lambda{|a,b| value }
          instance.attribute_set( attribute, ok_val[instance,0] )
          instance.send( "#{confirm}=", ok_val[instance,0] )
          instance.valid?(context).should be_true
        end
      end

      def create_expectation_for_error_value(value)
        confirm, context, attribute = @confirm, @context, @attribute
        description = "should not be valid if :%s %s".t( attribute, humanize_condition(value) )

        expect description do
          ok_val  = instance.attribute_get(attribute)
          err_val = value.is_a?(Proc) ? value : lambda{|a,b| value }

          instance.attribute_set( attribute, err_val[instance,0] )
          instance.send( "#{confirm}=", err_val[instance,1] )
          instance.valid?(context).should be_false

          instance.attribute_set( attribute, ok_val )
          instance.send( "#{confirm}=", ok_val )
          instance.valid?(context).should be_true
        end
      end

      def create_expectation_for_error_message(value)
        message, confirm, context, attribute = @message, @confirm, @context, @attribute
        description = "should have error \"%s\" if :%s %s".t( message, attribute, humanize_condition(value) )

        expect description do
          ok_val  = instance.attribute_get(attribute)
          err_val = value.is_a?(Proc) ? value : lambda{|a,b| value }
          err_msg = message.is_a?(Proc) ? message : lambda{|_| message }

          instance.attribute_set( attribute, err_val[instance,0] )
          instance.send( "#{confirm}=", err_val[instance,1] )
          instance.valid?(context)
          instance.errors[attribute].should include(err_msg[instance])

          instance.attribute_set( attribute, ok_val )
          instance.send( "#{confirm}=", ok_val )
          instance.valid?(context)
          instance.errors[attribute].should be_nil
        end
      end

  end

end
