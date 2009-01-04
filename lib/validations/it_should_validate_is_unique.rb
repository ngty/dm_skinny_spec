module DmSkinnySpec::Validations::ItShouldValidateIsUnique

  def it_should_validate_is_unique( attr, opts={} )
    DmSkinnySpec::Validations::ItShouldValidateIsUnique.validate attr, opts, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def validate_all( attr, context, opts )
        err_msg = (opts[:message]||'%s is already taken').t(humanize(attr))
        err_val = lambda { |eg| eg.instance(:other).attribute_get(attr) }

        validate_err_val( attr, err_val, context,
          "should not be valid if :#{attr} is not unique" )

        validate_err_msg( attr, err_val, err_msg, context,
          "should have error \"#{err_msg}\" if :#{attr} is not unique" )
      end
  end

end
