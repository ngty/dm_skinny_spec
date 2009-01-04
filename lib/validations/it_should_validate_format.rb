module DmSkinnySpec::Validations::ItShouldValidateFormat

  class UnexpectedFormat          < Exception ; end
  class UndefinedValidationValues < Exception ; end

  def it_should_validate_format( attr, opts={} )
    validator = DmSkinnySpec::Validations::ItShouldValidateFormat
    opts[:as] ||= opts.delete(:with)

    case opts[:as] 
      when :url, :email_address
        validator.validate( attr, opts, self )
      when Symbol
        raise UnexpectedFormat
      else
        opts[:reject].is_a?(Array) ?
          validator.validate( attr, opts, self ) : raise(UndefinedValidationValues)
    end
  end

  class << self

    include DmSkinnySpec::Validations::Common

    # NOTE: these examples are lifted from dm-validations specs
    
    INVALID_EMAILS = [
        '-- dave --@example.com', '[dave]@example.com', '.dave@example.com',
        'Max@Job 3:14', 'Job@Book of Job', 
        'J. P. \'s-Gravezande, a.k.a. The Hacker!@example.com'
      ]

    INVALID_URLS = [
        'http:// example.com', 'ftp://example.com',
        'http://.com', 'http://', 'test', '...'
      ]

    private


      def validate_all( attr, context, opts )
        opts[:allow_nil] = (val=opts.delete(:allow_nil)).nil? ? true : val

        case opts[:as]
          when :email_address
            validate_email_address( attr, context, opts )
          when :url 
            validate_url( attr, context, opts )
          else
            validate_err_vals( attr, context, opts[:reject], opts )
        end
      end

      def validate_err_vals( attr, context, err_vals, opts )
        err_msg = opts[:message] || '%s has an invalid format'.t(humanize(attr))

        err_vals.each do |err_val|
          err_msg_str = err_msg.is_a?(Proc) ? err_msg[err_val] : err_msg
          validate_err_val( attr, err_val, context, 
            %Q/should not be valid if :%s is "%s"/.t( attr, err_val ) )
          validate_err_msg( attr, err_val, err_msg_str, context, 
            %Q/should have error "%s" if :%s is "%s"/.t( err_msg_str, attr, err_val ) )
        end

        validate_nil_val( attr, context, opts[:allow_nil] )
      end

      def validate_email_address( attr, context, opts )
        # opts[:message] ||= lambda { |val| '%s is not a valid email address'.t(val) }
        validate_err_vals( attr, context, INVALID_EMAILS, opts )
      end

      def validate_url( attr, context, opts )
        # opts[:message] ||= lambda { |val| '%s is not a valid URL'.t(val) }
        validate_err_vals( attr, context, INVALID_URLS, opts )
      end

      def validate_nil_val( attr, context, allow_nil )
        if allow_nil
          validate_ok_val attr, nil, context, "should be valid if :#{attr} is nil"
        else
          validate_err_val attr, nil, context, "should not be valid if :#{attr} is nil"
        end
      end

  end

end
