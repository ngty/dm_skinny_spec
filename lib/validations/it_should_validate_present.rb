module DmSkinnySpec::Validations::ItShouldValidatePresent

  def it_should_validate_present( attr, opts={} )
    DmSkinnySpec::Validations::ItShouldValidatePresent.validate attr, opts, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def validate_all( attr, context, opts )
      default_msg = opts[:boolean] ? '%s must not be nil' : '%s must not be blank'
      err_msg = (opts[:message]||default_msg).t(humanize_attr(attr))
      test_args = { nil => 'nil' }.merge( opts[:boolean] ? {} : { '' => '""' } )

      test_args.each do | err_val, val_descrp |

        validate_err_val( attr, err_val, context,
          "should not be valid if :#{attr} is #{val_descrp}" )

        validate_err_msg( attr, err_val, err_msg, context,
          "should have error \"#{err_msg}\" if :#{attr} is #{val_descrp}" )
      end
    end

  end

end
