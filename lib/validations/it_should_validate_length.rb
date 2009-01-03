module DmSkinnySpec::Validations::ItShouldValidateLength

  class UndefinedComparison  < Exception ; end
  class UnexpectedComparison < Exception ; end

  def it_should_validate_length( attr, opts={} )
    validator = DmSkinnySpec::Validations::ItShouldValidateLength
    comparison_cnt = [ 
        opts[:min] ||= opts.delete(:minimum),
        opts[:max] ||= opts.delete(:maximum),
        opts[:is]  ||= opts.delete(:equals),
        opts[:in]  ||= opts.delete(:within)
      ].find_all { |t| t==nil }.length
      
    case comparison_cnt
      when 4 ; raise UndefinedComparison
      when 3 ; validator.validate( attr, opts, self )
      else   ; raise UnexpectedComparison
    end
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def validate_all( attr, context, opts )
        opts[:allow_nil] = (val=opts.delete(:allow_nil)).nil? ? true : val

        if range = opts.delete(:in)
          validate_range( attr, context, range, opts )
        elsif equal = opts.delete(:is)
          validate_equal( attr, context, equal, opts )
        elsif min = opts.delete(:min)
          validate_min( attr, context, min, opts )
        elsif max = opts.delete(:max)
          validate_max( attr, context, max, opts )
        end
      end

      def validate_equal( attr, context, equal, opts )
        err_msg = (opts[:message]||'%s must be %s characters long') % 
          [ humanize_attr(attr), equal ]
        validate_range attr, context, equal..equal, opts.merge(:message=>err_msg)
      end

      def validate_range( attr, context, range, opts )
        err_msg = (opts[:message]||'%s must be between %s and %s characters long') %
          [ humanize_attr(attr), range.min, range.max ]

        if range.min == 0
          opts.update( :message => err_msg )
          validate_max attr, context, range.max, opts
          validate_min attr, context, range.min, opts
        else
          opts.update( :message => err_msg, :is_max => false )
          validate_max attr, context, range.max, opts
          validate_min attr, context, range.min, opts
        end
      end

      def validate_max( attr, context, max, opts )
        is_max = (val=opts[:is_max]).nil? ? true : nil
        err_msg = (opts[:message]||'%s must be less than %s characters long') % 
          [ humanize_attr(attr), max ]
        err_val = 'x' * max.succ

        validate_nil_val attr, context, opts[:allow_nil], 
          opts.merge( :message => err_msg, :is_max => is_max )

        validate_err_val attr, err_val, context,
          "should not be valid if :#{attr} is more than #{max} chars long"

        validate_err_msg attr, err_val, err_msg, context,
          "should have error \"#{err_msg}\" if :#{attr} is more than #{max} chars long"
      end

      def validate_min( attr, context, min, opts )
        err_msg = (opts[:message]||'%s must be more than %s characters long') % 
          [ humanize_attr(attr), min ]

        if min.pred >= 0
          err_val = 'x' * min.pred

          validate_nil_val attr, context, opts[:allow_nil], 
            opts.merge( :message => err_msg )

          validate_err_val attr, err_val, context,
            "should not be valid if :#{attr} is less than #{min} chars long"

          validate_err_msg attr, err_val, err_msg, context,
            "should have error \"#{err_msg}\" if :#{attr} is less than #{min} chars long"
        end
      end

      def validate_nil_val( attr, context, allow_nil, opts )
        if allow_nil or opts[:is_max]
          validate_ok_val attr, nil, context, "should be valid if :#{attr} is nil"
        else
          validate_err_val attr, nil, context, "should not be valid if :#{attr} is nil"
        end
      end

  end

end
