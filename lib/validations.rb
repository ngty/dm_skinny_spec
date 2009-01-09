if Object.const_defined?('DataMapper') && DataMapper.const_defined?('Validate')

  module DmSkinnySpec::Validations

    module Common

      def run( attribute, options, example_group )
        @example_group  = example_group
        @attribute      = attribute
        @attribute_name = Extlib::Inflection.humanize(attribute.to_s)
        @context        = options.delete(:when) || :default
        @condition      = options.delete(:condition) # not yet supported
        @message        = options.delete(:message)
        @options        = options

        validate
      end

      private

        def run_example( description, &proc )
          @example_group.it example_description_for_context(description), &proc
        end

        def validate_error_values( values, condition_description='is %s' )
          @condition_description = condition_description
          [values].flatten.each do |value|
            validate_error_value   value
            validate_error_message value
          end
        end

        def validate_error_value(value)
          context, attribute = @context, @attribute
          description = "should not be valid if :%s %s".t( attribute, humanize_condition(value) )

          run_example description do
            ok_val  = instance.attribute_get(attribute)
            err_val = value.is_a?(Proc) ? value : lambda{|_| value }

            instance.attribute_set( attribute, err_val[self] )
            instance.valid?(context).should be_false

            instance.attribute_set( attribute, ok_val )
            instance.valid?(context).should be_true
          end
        end

        def validate_error_message(value)
          context, attribute, message = @context, @attribute, @message
          description = "should have error \"%s\" if :%s %s" %
            [ message, attribute, humanize_condition(value) ]

          run_example description do
            ok_val  = instance.attribute_get(attribute)
            err_val = value.is_a?(Proc) ? value : lambda{|_| value }
            err_msg = message.is_a?(Proc) ? message : lambda{ |_| message }

            instance.attribute_set( attribute, err_val[self] )
            instance.valid?(context)
            instance.errors[attribute].should include(err_msg[self])

            instance.attribute_set( attribute, ok_val )
            instance.valid?(context)
            instance.errors[attribute].should be_nil
          end
        end

        def validate_ok_values( values, condition_description='is %s' )
          @condition_description = condition_description
          [values].flatten.each do |value|
            validate_ok_value value
          end
        end

        def validate_ok_value(value)
          context, attribute = @context, @attribute
          description = "should be valid if :%s %s".t( attribute, humanize_condition(value) )

          run_example description do
            ok_val = value.is_a?(Proc) ? value : lambda{|_| value }
            instance.attribute_set( attribute, ok_val[self] )
            instance.valid?(context).should be_true
          end
        end

        def example_description_for_context(description)
          description += " (for :#{@context})" unless @context == :default
          description
        end

        def humanize_condition(value)
          @condition_description %
            case value
              when nil    ; 'nil'
              when String ; '"%s"'.t(value)
              else        ; value.to_s
            end
        end

    end
  end

  require 'validations/it_should_validate_absent'
  require 'validations/it_should_validate_present'
  require 'validations/it_should_validate_format'
  require 'validations/it_should_validate_length'
  require 'validations/it_should_validate_is_accepted'
  require 'validations/it_should_validate_is_confirmed'
  require 'validations/it_should_validate_is_unique'

  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateAbsent)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidatePresent)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateFormat)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateLength)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateIsAccepted)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateIsConfirmed)
  Spec::Example::ExampleGroup.extend(DmSkinnySpec::Validations::ItShouldValidateIsUnique)

end

