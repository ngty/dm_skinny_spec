module DmSkinnySpec::Validations::ItShouldValidateIsAccepted

  def it_should_validate_is_accepted( attr, opts={} )
    DmSkinnySpec::Validations::ItShouldValidateIsAccepted.validate attr, opts, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def validate_all( attr, context, opts )
      err_msg = (opts[:message]||'%s is not accepted').t(humanize(attr))

      validate_valids( attr, context, opts[:valids] )
      validate_invalids( attr, context, opts[:invalids], err_msg )
      validate_nil( attr, context, opts[:allow_nil], err_msg )
    end

    def validate_valids( attr, context, ok_vals )
      ( ok_vals || [ '1', 1, true, 'true', 't' ] ).each do |ok_val|
        validate_ok_val( attr, ok_val, context, 
          "should be valid if :#{attr} is " + humanize(ok_val) )
      end
    end

    def validate_invalids( attr, context, err_vals, err_msg )
      ( err_vals || [ '0', 0, false, 'false', 'f' ] ).each do |err_val|
        validate_err_val( attr, err_val, context, 
          "should not be valid if :#{attr} is " + humanize(err_val) )
        validate_err_msg( attr, err_val, err_msg, context, 
          "should have error \"#{err_msg}\" if :#{attr} is " + humanize(err_val) )
      end
    end

    def validate_nil( attr, context, allow_nil, err_msg )
      ( allow_nil.nil? ? true : allow_nil ) ?
        validate_valids( attr, context, [nil] ) :
        validate_invalids(  attr, context, [nil], err_msg )
    end

  end

end
