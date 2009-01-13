module DmSkinnySpec::Validations::ItShouldValidateIsUnique

  def it_should_validate_is_unique( attribute, options={} )
    builder = DmSkinnySpec::Validations::ItShouldValidateIsUnique
    builder.create_expectations_for attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def create_expectations
        @message ||= '%s is already taken'.t(@attribute_name)
        attribute = @attribute

        value_proc = lambda do |example| 
          example.instance(:other).attribute_get(attribute) 
        end

        create_expectations_for_values value_proc, :description => 'is not unique'
      end
  end

end
