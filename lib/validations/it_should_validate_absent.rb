module DmSkinnySpec::Validations::ItShouldValidateAbsent

  def it_should_validate_absent( attribute, options={} )
    builder = DmSkinnySpec::Validations::ItShouldValidateAbsent
    builder.create_expectations_for attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def create_expectations
      @message ||= '%s must be absent'.t(@attribute_name)

      case @options[:boolean]
        when true ; create_expectations_for_values true
        else      ; create_expectations_for_values 'x', :description => 'is not blank'
      end
    end

  end

end
