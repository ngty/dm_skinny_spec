module DmSkinnySpec::Validations::ItShouldValidateIsConfirmed

  def it_should_validate_is_confirmed( attribute, options={} )
    DmSkinnySpec::Validations::ItShouldValidateIsConfirmed.run attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def validate
      @message ||= '%s does not match the confirmation'.t(@attribute_name)
      @confirm = @options[:confirm] || "#{@attribute}_confirmation".to_sym
      confirm, attribute = @confirm, @attribute

      value_proc = lambda { |instance,i|
        '%s.%s'.t( (@orig_ok_value||=instance.attribute_get(attribute)), i )
      }

      validate_ok_values value_proc, 'matches confirmation'
      validate_error_values value_proc, 'does not match confirmation'

      case @options[:allow_nil]
        when true, nil ; validate_ok_values nil, 'is nil'
        else           ; validate_error_values nil, 'is nil'
      end
    end

    def validate_ok_value(value)
      confirm, context, attribute = @confirm, @context, @attribute
      description = "should be valid if :%s %s".t( attribute, humanize_condition(value) )

      run_example description do
        ok_val = value.is_a?(Proc) ? value : lambda{|a,b| value }
        instance.attribute_set( attribute, ok_val[instance,0] )
        instance.send( "#{confirm}=", ok_val[instance,0] )
        instance.valid?(context).should be_true
      end
    end

    def validate_error_value(value)
      confirm, context, attribute = @confirm, @context, @attribute
      description = "should not be valid if :%s %s".t( attribute, humanize_condition(value) )

      run_example description do
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

    def validate_error_message(value)
      message, confirm, context, attribute = @message, @confirm, @context, @attribute
      description = "should have error \"%s\" if :%s %s".t( message, attribute, humanize_condition(value) )

      run_example description do
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
