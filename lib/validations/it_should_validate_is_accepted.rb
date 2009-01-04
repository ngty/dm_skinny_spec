module DmSkinnySpec::Validations::ItShouldValidateIsAccepted

  def it_should_validate_is_accepted( attr, opts={} )
    DmSkinnySpec::Validations::ItShouldValidateIsAccepted.validate attr, opts, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def validate_all( attr, context, opts )
      err_msg = (opts[:message]||'%s is not accepted').t(humanize(attr))

      validate_err_vals attr, context, opts[:reject], err_msg
      validate_nil_val  attr, context, opts[:allow_nil], err_msg
    end

    def validate_err_vals( attr, context, err_vals, err_msg )
      ( err_vals || [ '0', 0, false, 'false', 'f' ] ).each do |err_val|
        validate_err_val attr, err_val, context, 
          "should not be valid if :#{attr} is #{humanize(err_val)}"
        validate_err_msg attr, err_val, err_msg, context, 
          "should have error \"#{err_msg}\" if :#{attr} is #{humanize(err_val)}"
      end
    end

    def validate_nil_val( attr, context, allow_nil, err_msg )
      if allow_nil == false
        validate_err_vals attr, context, [nil], err_msg
      else
        validate_ok_val attr, nil, context, "should be valid if :#{attr} is nil"
      end
    end

  end

end
