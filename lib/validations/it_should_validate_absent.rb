module DmSkinnySpec::Validations::ItShouldValidateAbsent

  def it_should_validate_absent( attr, opts={} )
    DmSkinnySpec::Validations::ItShouldValidateAbsent.validate attr, opts, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def validate_all( attr, context, opts )
      err_msg = (opts[:message]||'%s must be absent').t(humanize_attr(attr))

      unless opts[:boolean]
        validate_err_val( attr, 'x', context,
          "should not be valid if :#{attr} is not blank" )
        validate_err_msg( attr, 'x', err_msg, context,
          "should have error \"#{err_msg}\" if :#{attr} is not blank" )
      else
        validate_err_val( attr, true, context,
          "should not be valid if :#{attr} is true" )
        validate_err_msg( attr, true, err_msg, context,
          "should have error \"#{err_msg}\" if :#{attr} is true" )
      end
    end

  end

end