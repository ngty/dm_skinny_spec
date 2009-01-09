module DmSkinnySpec::Validations::ItShouldValidateFormat

  class UnexpectedFormat      < Exception ; end
  class UndefinedRejectValues < Exception ; end

  def it_should_validate_format( attribute, options={} )
    validator =  DmSkinnySpec::Validations::ItShouldValidateFormat
    options[:as] ||= options.delete(:with)

    case options[:as]
      when :url, :email_address
        validator.run attribute, options, self
      when Symbol
        raise UnexpectedFormat
      else
        raise UndefinedRejectValues unless options[:reject]
        validator.run attribute, options, self
    end
  end

  class << self

    include DmSkinnySpec::Validations::Common

    attr_writer :invalid_emails, :invalid_urls

    def invalid_emails
      @invalid_emails || [
        # Lifted from dm-validations specs
        '-- dave --@example.com', 
        '[dave]@example.com', 
        '.dave@example.com',
        'Max@Job 3:14', 
        'Job@Book of Job', 
        'J. P. \'s-Gravezande, a.k.a. The Hacker!@example.com'
      ]
    end

    def invalid_urls
      @invalid_urls = [
        # Lifted from dm-validations specs
        'http:// example.com', 
        'ftp://example.com',
        'http://.com', 
        'http://', 
        'test', 
        '...'
      ]
    end

    private

      def validate
        @message ||= '%s has an invalid format'.t(@attribute_name)

        error_values = 
          case @options[:as]
            when :email_address ; invalid_emails
            when :url           ; invalid_urls
            else                ; @options.delete(:reject)
          end

        case @options[:allow_nil]
          when nil, true ; validate_ok_values nil
          else           ; error_values << nil
        end

        validate_error_values error_values
      end

  end

end
