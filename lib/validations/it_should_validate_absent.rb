module DmSkinnySpec::Validations::ItShouldValidateAbsent

  def it_should_validate_absent( attribute, options={} )
    DmSkinnySpec::Validations::ItShouldValidateAbsent.run attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def validate
      @message ||= '%s must be absent'.t(@attribute_name)

      if @options[:boolean]
        validate_error_values true
      else
        validate_error_values 'x', "not blank"
      end
    end

  end

end
