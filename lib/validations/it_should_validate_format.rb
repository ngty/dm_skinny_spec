module DmSkinnySpec::Validations::ItShouldValidateFormat

  class UnexpectedFormat      < Exception ; end
  class UndefinedRejectValues < Exception ; end

  def it_should_validate_format( attribute, options={} )
    options[:as] ||= options.delete(:with)
    builder = DmSkinnySpec::Validations::ItShouldValidateFormat

    case options[:as]
      when :url, :email_address
        builder.create_expectations_for attribute, options, self
      when Symbol
        raise UnexpectedFormat
      else
        raise UndefinedRejectValues unless options[:reject]
        builder.create_expectations_for attribute, options, self
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

      def create_expectations
        @message ||= '%s has an invalid format'.t(@attribute_name)

        error_values = 
          case @options[:as]
            when :email_address ; invalid_emails
            when :url           ; invalid_urls
            else                ; @options.delete(:reject)
          end

        if @allow_nil
          create_expectations_for_values nil, :type => :ok
        else 
          create_expectations_for_values [ error_values, nil ].flatten
        end
      end

  end

end
