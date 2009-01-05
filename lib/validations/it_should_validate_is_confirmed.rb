module DmSkinnySpec::Validations::ItShouldValidateIsConfirmed

  def it_should_validate_is_confirmed( attr, opts={} )
    DmSkinnySpec::Validations::ItShouldValidateIsConfirmed.validate attr, opts, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def validate_all( attr, context, opts )
      err_msg = (opts[:message]||'%s does not match the confirmation').t(humanize(attr))
      allow_nil = (val=opts[:allow_nil]).nil? ? true : val
      confirm = opts[:confirm] || "#{attr}_confirmation".to_sym

      validate_err_val_and_err attr, confirm, context, err_msg
      validate_nil_val_and_err attr, confirm, context, err_msg, allow_nil
    end

    def validate_err_val_and_err( attr, confirm, context, err_msg )
      attr_err_val = lambda { |instance| '%s.0'.t(instance.attribute_get(attr)) }
      confirm_err_val = lambda { |instance| '%s.1'.t(instance.send(confirm)) }

      validate_err_val attr, confirm, attr_err_val, confirm_err_val, context,
        "should not be valid if :#{attr} does not match confirmation"

      validate_err_msg attr, confirm, attr_err_val, confirm_err_val, err_msg, context,
        "should have error \"#{err_msg}\" if :#{attr} does not match confirmation"
    end

    def validate_nil_val_and_err( attr, confirm, context, err_msg, allow_nil )
      if allow_nil
        validate_ok_nil_val attr, confirm, context, 
          "should be valid if :#{attr} and confirmation are nil"
      else
        validate_err_val attr, confirm, nil, nil, context, 
          "should not be valid if :#{attr} and confirmation are nil"
        validate_err_msg attr, confirm, nil, nil, err_msg, context, 
          "should have error \"#{err_msg}\" if :#{attr} and confirmation are nil"
      end
    end

    def validate_ok_nil_val( attr, confirm, context, example_str )
      example.it example_str_for_context( example_str, context ) do
        instance.attribute_set( attr, nil )
        instance.send( "#{confirm}=", nil )
        instance.valid?(context).should be_true
      end
    end

    def validate_err_val( attr, confirm, attr_err_val, confirm_err_val, context, example_str )
      example.it example_str_for_context( example_str, context ) do
        ok_val = instance.attribute_get(attr)
        attr_err_val = attr_err_val[instance] if attr_err_val.is_a?(Proc)
        confirm_err_val = confirm_err_val[instance] if confirm_err_val.is_a?(Proc)

        instance.attribute_set( attr, attr_err_val )
        instance.send( "#{confirm}=", confirm_err_val )
        instance.valid?(context).should be_false

        instance.attribute_set( attr, ok_val )
        instance.send( "#{confirm}=", ok_val )
        instance.valid?(context).should be_true
      end
    end

    def validate_err_msg( attr, confirm, attr_err_val, confirm_err_val, err_msg, context, example_str )
      example.it example_str_for_context( example_str, context ) do
        ok_val = instance.attribute_get(attr)
        attr_err_val = attr_err_val[instance] if attr_err_val.is_a?(Proc)
        confirm_err_val = confirm_err_val[instance] if confirm_err_val.is_a?(Proc)

        instance.attribute_set( attr, attr_err_val )
        instance.send( "#{confirm}=", confirm_err_val )
        instance.valid?(context)
        instance.errors[attr].should include(err_msg)

        instance.attribute_set( attr, ok_val )
        instance.send( "#{confirm}=", ok_val )
        instance.valid?(context)
        instance.errors[attr].should be_nil
      end
    end

  end

end
