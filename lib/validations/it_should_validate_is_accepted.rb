module DmSkinnySpec::Validations::ItShouldValidateIsAccepted

  def it_should_validate_is_accepted( attribute, options={} )
    DmSkinnySpec::Validations::ItShouldValidateIsAccepted.run attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def validate
      @message   ||= '%s is not accepted'.t(@attribute_name)
      error_values = @options.delete(:reject) || [ '0', 0, false, 'false', 'f' ]

      case @options[:allow_nil]
        when nil, true ; validate_ok_values nil
        else           ; error_values << nil
      end

      validate_error_values error_values
    end

  end

end
