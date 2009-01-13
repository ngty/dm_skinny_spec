module DmSkinnySpec::Validations::ItShouldValidateIsAccepted

  def it_should_validate_is_accepted( attribute, options={} )
    builder = DmSkinnySpec::Validations::ItShouldValidateIsAccepted
    builder.create_expectations_for attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    def create_expectations
      @message   ||= '%s is not accepted'.t(@attribute_name)
      error_values = @options.delete(:reject) || [ '0', 0, false, 'false', 'f' ]

      if @allow_nil
        create_expectations_for_values nil, :type => :ok
      else
        error_values << nil
      end

      create_expectations_for_values error_values
    end

  end

end
