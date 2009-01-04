if Object.const_defined?('DataMapper') && DataMapper.const_defined?('Validate')

  module DmSkinnySpec::Validations

    module Common

      def validate( attr, opts, example )
        @example = example
        validate_all attr, (opts.delete(:when)||:default), opts
      end

      private

        def example
          @example
        end

        def validate_ok_val( attr, ok_val, context, example_str )
          example.it example_str_for_context( example_str, context ) do
            instance.attribute_set( attr, ok_val.is_a?(Proc)?ok_val[self]:ok_val )
            instance.valid?(context).should be_true
          end
        end

        def validate_err_val( attr, err_val, context, example_str )
          example.it example_str_for_context( example_str, context ) do
            ok_val = instance.attribute_get(attr)

            instance.attribute_set( attr, err_val.is_a?(Proc)?err_val[self]:err_val )
            instance.valid?(context).should be_false

            instance.attribute_set( attr, ok_val )
            instance.valid?(context).should be_true
          end
        end

        def validate_err_msg( attr, err_val, err_msg, context, example_str )
          example.it example_str_for_context( example_str, context ) do
            ok_val = instance.attribute_get(attr)

            instance.attribute_set( attr, err_val.is_a?(Proc)?err_val[self]:err_val )
            instance.valid?(context)
            instance.errors[attr].should include(err_msg.is_a?(Proc)?err_msg[err_val]:err_msg)

            instance.attribute_set( attr, ok_val )
            instance.valid?(context)
            instance.errors[attr].should be_nil
          end
        end

        def example_str_for_context( example_str, context )
          example_str += " (for :#{context})" unless context == :default
          example_str
        end

        def humanize(arg)
          case arg
            when Symbol ; Extlib::Inflection.humanize(arg.to_s)
            when nil    ; 'nil'
            when String ; '"%s"'.t(arg)
            else        ; arg.to_s
          end
        end

    end
  end


  require 'validations/it_should_validate_present'
  require 'validations/it_should_validate_absent'
  require 'validations/it_should_validate_is_accepted'
  require 'validations/it_should_validate_is_unique'
  require 'validations/it_should_validate_length'
  require 'validations/it_should_validate_format'

  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidatePresent)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateAbsent)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateIsAccepted)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateIsUnique)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateLength)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateFormat)

end

