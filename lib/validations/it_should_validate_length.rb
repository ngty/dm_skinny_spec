module DmSkinnySpec::Validations::ItShouldValidateLength

  class UndefinedComparison  < Exception ; end
  class UnexpectedComparison < Exception ; end

  def it_should_validate_length( attribute, options={} )
    validator = DmSkinnySpec::Validations::ItShouldValidateLength
    comparison_cnt = [ 
        options[:min] ||= options.delete(:minimum),
        options[:max] ||= options.delete(:maximum),
        options[:is]  ||= options.delete(:equals),
        options[:in]  ||= options.delete(:within)
      ].find_all { |t| t==nil }.length
      
    case comparison_cnt
      when 4 ; raise UndefinedComparison
      when 3 ; DmSkinnySpec::Validations::ItShouldValidateLength.run attribute, options, self 
      else   ; raise UnexpectedComparison
    end
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def validate
        @allow_nil = 
          case @options[:allow_nil]
            when nil, true ; true
            else           ; false
          end

        if range = @options[:in] 
          validate_range range
        elsif equal = @options[:is]
          validate_equal equal
        elsif min = @options[:min]
          validate_min min
        elsif max = @options[:max]
          validate_max max
        end
      end

      def validate_equal value
        @message ||= '%s must be %s characters long'.t( @attribute_name, value )
        validate_range value..value
      end

      def validate_range range
        max, min = range.max, range.min
        @message ||= '%s must be between %s and %s characters long'.t( @attribute_name, min, max )

        validate_max max, min==0
        validate_min min
      end

      def validate_max value, zero_ok=nil
        @message ||= '%s must be less than %s characters long'.t( @attribute_name, value )

        validate_error_values 'x'*value.succ, "is more than #{value} chars long" 

        if @options[:allow_nil]!=false or zero_ok!=false
          validate_ok_values nil
        else
          validate_error_values nil
        end
      end

      def validate_min value
        @message ||= '%s must be more than %s characters long'.t( @attribute_name, value )

        if value.pred >= 0
          validate_error_values 'x'*value.pred, "is less than #{value} chars long"

          case @options[:allow_nil]
            when true, nil ; validate_ok_values    nil
            else           ; validate_error_values nil
          end
        end
      end

  end

end
