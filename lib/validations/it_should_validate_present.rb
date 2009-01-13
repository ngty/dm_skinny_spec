module DmSkinnySpec::Validations::ItShouldValidatePresent

  def it_should_validate_present( attribute, options={} )
    builder = DmSkinnySpec::Validations::ItShouldValidatePresent
    builder.create_expectations_for attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def create_expectations
      if @options[:boolean]
        @message ||= '%s must not be nil'.t(@attribute_name)
        create_expectations_for_values nil
      else
        @message ||= '%s must not be blank'.t(@attribute_name)
        create_expectations_for_values [ nil, '' ]
      end
    end

  end

end
