module DmSkinnySpec::Validations::ItShouldValidateIsUnique

  def it_should_validate_is_unique( attribute, options={} )
    DmSkinnySpec::Validations::ItShouldValidateIsUnique.run attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def validate
        @message ||= '%s is already taken'.t(@attribute_name)
        attribute = @attribute

        value_proc = lambda do |example| 
          example.instance(:other).attribute_get(attribute) 
        end

        validate_error_values value_proc, 'is not unique'
      end
  end

end
