module DmSkinnySpec::Validations

  module Common

    def create_expectations_for( attribute, options, example_group )
      @example_group  = example_group
      @attribute      = attribute
      @attribute_name = Extlib::Inflection.humanize(attribute.to_s)
      @context        = options.delete(:when) || :default
      @message        = options.delete(:message)
      @allow_nil      = (bool=options.delete(:allow_nil)).nil? ? true : bool
      @options        = options

      create_expectations
    end

    private

      def expect( description, &proc )
        description += " (for :#{@context})" unless @context == :default
        @example_group.it description, &proc
      end

      def create_expectations_for_values( values, options={} )
        @condition_description = options.delete(:description) || 'is %s'
        
        expectation_proc = 
          case options[:type]
            when nil, :error:
              lambda do |value|
                create_expectation_for_error_value value
                create_expectation_for_error_message value
              end
            else
              lambda do |value|
                create_expectation_for_ok_value value
              end
          end

        [values].flatten.each { |value| expectation_proc[value] }
      end

      def create_expectation_for_error_value(value)
        context, attribute = @context, @attribute
        description = "should not be valid if :%s %s".t( attribute, humanize_condition(value) )

        expect description do
          ok_val  = instance.attribute_get(attribute)
          err_val = value.is_a?(Proc) ? value : lambda{|_| value }

          instance.attribute_set( attribute, err_val[self] )
          instance.valid?(context).should be_false

          instance.attribute_set( attribute, ok_val )
          instance.valid?(context).should be_true
        end
      end

      def create_expectation_for_error_message(value)
        context, attribute, message = @context, @attribute, @message
        description = "should have error \"%s\" if :%s %s" %
          [ message, attribute, humanize_condition(value) ]

        expect description do
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

      def create_expectation_for_ok_value(value)
        context, attribute = @context, @attribute
        description = "should be valid if :%s %s".t( attribute, humanize_condition(value) )

        expect description do
          ok_val = value.is_a?(Proc) ? value : lambda{|_| value }
          instance.attribute_set( attribute, ok_val[self] )
          instance.valid?(context).should be_true
        end
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
