module DmSkinnySpec::Validations::ItShouldValidatePresent

  def it_should_validate_present( attr, opts={} )
    DmSkinnySpec::Validations::ItShouldValidatePresent.validate attr, opts, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def validate_all( attr, context, opts )
      is_bool = opts[:boolean]
      opts[:message] ||= is_bool ? '%s must not be nil' : '%s must not be blank' 
      err_msg = opts[:message].t(humanize(attr))

      ( is_bool ? [nil] : [ nil, '' ] ).each do |err_val|
        validate_err_val( attr, err_val, context,
          "should not be valid if :#{attr} is " + humanize(err_val) )
        validate_err_msg( attr, err_val, err_msg, context,
          "should have error \"#{err_msg}\" if :#{attr} is " + humanize(err_val) )
      end
    end

  end

end
