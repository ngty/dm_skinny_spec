module DmSkinnySpec::Validations::ItShouldValidateLength

  class UndefinedComparison  < Exception ; end
  class UnexpectedComparison < Exception ; end

  def it_should_validate_length( attribute, options={} )
    builder = DmSkinnySpec::Validations::ItShouldValidateLength
    comparison_cnt = [ 
        options[:min] ||= options.delete(:minimum),
        options[:max] ||= options.delete(:maximum),
        options[:is]  ||= options.delete(:equals),
        options[:in]  ||= options.delete(:within)
      ].find_all { |t| t==nil }.length
      
    case comparison_cnt
      when 4 ; raise UndefinedComparison
      when 3 ; builder.create_expectations_for attribute, options, self 
      else   ; raise UnexpectedComparison
    end
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def create_expectations
        if range = @options[:in] 
          create_expectation_for_range range
        elsif equal = @options[:is]
          create_expectation_for_equal equal
        elsif min = @options[:min]
          create_expectation_for_min min
        elsif max = @options[:max]
          create_expectation_for_max max
        end
      end

      def create_expectation_for_equal value
        @message ||= '%s must be %s characters long'.t( @attribute_name, value )
        create_expectation_for_range value..value
      end

      def create_expectation_for_range range
        max, min = range.max, range.min
        @message ||= '%s must be between %s and %s characters long'.t( @attribute_name, min, max )

        create_expectation_for_max max, min==0
        create_expectation_for_min min
      end

      def create_expectation_for_max value, zero_ok=nil
        @message ||= '%s must be less than %s characters long'.t( @attribute_name, value )

        create_expectations_for_values 'x'*value.succ, 
          :description => "is more than #{value} chars long", :type => :error

        create_expectations_for_values nil,
          :type => ( @allow_nil or zero_ok!=false ) ? :ok : :error
      end

      def create_expectation_for_min value
        @message ||= '%s must be more than %s characters long'.t( @attribute_name, value )

        if value.pred >= 0
          create_expectations_for_values 'x'*value.pred, 
            :description => "is less than #{value} chars long"

          create_expectations_for_values nil, 
            :type => @allow_nil ? :ok : :error
        end
      end

  end

end
