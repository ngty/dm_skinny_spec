module DmSkinnySpec::Validations::ItShouldValidatePresent

  def it_should_validate_present( attribute, options={} )
    DmSkinnySpec::Validations::ItShouldValidatePresent.run attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def validate
      if @options[:boolean]
        @message ||= '%s must not be nil'.t(@attribute_name)
        validate_error_values nil
      else
        @message ||= '%s must not be blank'.t(@attribute_name)
        validate_error_values [ nil, '' ]
      end
    end

  end

end
