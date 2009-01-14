module DmSkinnySpec::Validations::ItShouldValidateLength

  class UndefinedComparison  < Exception ; end
  class UnexpectedComparison < Exception ; end

  ##
  # Creates expectations for verifying that +attribute+'s length is:
  # * equal to, 
  # * less than, 
  # * greater than, or 
  # * within a certain range 
  #
  # Supported options are:
  # * :maximum ... maximum allowable length
  # * :max ... alias of :maximum
  # * :minimum ... minimum allowable length
  # * :min ... alias of :minimum
  # * :equals ... must be equal to this length
  # * :is ... alias of :equal
  # * :within ... must be within this range of length
  # * :in ... alias of :within
  # * :allow_nil ... whether nil value may be accepted (not applicable for :max), default is true
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
  #     property :id,         Serial
  #     property :first_name, String, :auto_validation => false
  #     property :last_name,  String, :auto_validation => false
  #     property :email,      String, :auto_validation => false
  #     property :address,    String, :auto_validation => false
  #   
  #     validates_length :first_name, :min => 2,      :allow_nil => false
  #     validates_length :last_name,  :max => 10,     :when => :last_name_test      
  #     validates_length :email,      :is  => 20,     :allow_nil => false
  #     validates_length :address,    :in  => 20..30, :allow_nil => true
  #   end
  #   
  #   User.fix {{ 
  #     :first_name => /\w{3,10}/.gen,
  #     :last_name  => /\w{3,10}/.gen,
  #     :email      => /\w{10}/.gen + '@fmail.com',
  #     :address    => /\w{4,9} \w{4,9} \w{10}/.gen,
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
  #     it_should_validate_length :last_name, :max => 10, :when => :last_name_test
  #     it_should_validate_length :first_name, :min => 2, :allow_nil => false
  #     it_should_validate_length :email, :is => 20, :allow_nil => false
  #     it_should_validate_length :address, :in => 20..30, :allow_nil => true
  #   end
  #   
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
