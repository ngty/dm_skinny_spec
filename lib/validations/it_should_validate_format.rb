module DmSkinnySpec::Validations::ItShouldValidateFormat

  class UnexpectedFormat      < Exception ; end
  class UndefinedRejectValues < Exception ; end

  ###
  # Creates expectations for verifying that +attribute+ conforms to a specified
  # format.
  #
  # Supported options are:
  # * :as ... predefined format, currently only support :email_address & :url
  # * :with ... alias of :as
  # * :reject ... array of rejected values, MUST be specifed if :as (& :with) is missing
  # * :allow_nil ... whether nil value may be accepted, default is true
  # * :message ... customize the expected error message (optional)
  # * :when    ... context in which the validation applies (optional)
  # 
  # Notes:
  # * you have to provide an instance() method in your specs to return valid
  #   instances of your model (see the example below).
  # 
  # Examples:
  #
  #   class User
  #     include DataMapper::Resource
  #   
  #     ADDRESS_FORMAT = /\w{5,10} (st|ave), republic (moon|mars)/
  #     ADDRESS_FORMAT_PROC = lambda { |s| s=~ADDRESS_FORMAT }
  #   
  #     property :id,         Serial
  #     property :name,       String, :auto_validation => false
  #     property :address,    String, :auto_validation => false
  #     property :email,      String, :auto_validation => false
  #     property :blog_url,   String, :auto_validation => false
  #   
  #     validates_format :name, :as => /^\w{5,10}$/, :allow_nil => true
  #     validates_format :email, :as => :email_address, :allow_nil => false
  #     validates_format :address, :as => ADDRESS_FORMAT_PROC, :allow_nil => true, :when => :address_test
  #     validates_format :blog_url, :as => :url, :allow_nil => true, :message => "Blog URL looks fishy"
  #   end
  #   
  #   User.fix {{ 
  #     :name       => /\w{5,10}/.gen,
  #     :email      => /\w{10}/.gen + '@fmail.com',
  #     :address    => User::ADDRESS_FORMAT.gen,
  #     :blog_url   => /http:\/\/\w{5,10}.(com|org|net)/.gen
  #   }}
  #   
  #   describe User do
  #   
  #     before do
  #       User.auto_migrate!
  #       @instances = {}
  #     end
  #   
  #     def instance(id=:default)
  #       @instances[id] ||= User.gen
  #     end
  #   
  #     def self.invalids
  #       @invalid_proc ||= lambda { |key| {
  #         :address => [ 'eeffgg st, republic sun', 'aa ave, republic mars' ],
  #         :name    => [ 'aabb', 'aabbccddeeff' ]
  #       }[key] }
  #     end
  #   
  #     it_should_validate_format :name, :reject => invalids[:name]
  #     it_should_validate_format :name, :reject => invalids[:name], :allow_nil => true
  #     it_should_validate_format :address, :reject => invalids[:address], :when => :address_test
  #     it_should_validate_format :email, :as => :email_address, :allow_nil => false
  #     it_should_validate_format :blog_url, :with => :url, :message => "Blog URL looks fishy"
  #   
  #   end
  #
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
