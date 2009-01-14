module DmSkinnySpec::Validations::ItShouldValidateIsAccepted

  ###
  # Creates expectations for verifying that +attribute+'s value is in the set of 
  # accepted values.
  #
  # Supported options are:
  # * :reject ... array of rejected values, default is [ '0', 0, false, 'false', 'f' ]
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
  #   class Agreement
  #  
  #     include DataMapper::Resource
  #  
  #     DEFAULT_TRUES = [ '1', 1, 'true', true, 't' ]
  #  
  #     property :id,           Serial
  #     property :license,      String, :auto_validation => false
  #     property :terms,        String, :auto_validation => false
  #     property :more_terms,   String, :auto_validation => false
  #     property :more_license, String, :auto_validation => false
  #  
  #     validates_is_accepted :terms,        :allow_nil => true
  #     validates_is_accepted :more_license, :allow_nil => false
  #     validates_is_accepted :more_terms,   :accept    => [ '1', 1 ]
  #     validates_is_accepted :license,      :message   => 'We hate software pirates'
  #   end
  #  
  #   Agreement.fix {{ 
  #     :terms         => Agreement::DEFAULT_TRUES.pick,
  #     :license       => Agreement::DEFAULT_TRUES.pick,
  #     :more_license  => Agreement::DEFAULT_TRUES.pick,
  #     :more_terms    => [ '1', 1 ].pick
  #   }}
  #  
  #  describe Agreement do
  #  
  #    before do
  #      Agreement.auto_migrate!
  #      @instances = {}
  #    end
  #  
  #    def instance(id=:default)
  #      @instances[id] ||= Agreement.gen
  #    end
  #  
  #    it_should_validate_is_accepted :more_terms, :reject => [ '0', 0, 'true', true, 't', 'false', false, 'f' ]
  #    it_should_validate_is_accepted :license, :message => 'We hate software pirates'
  #    it_should_validate_is_accepted :terms
  #    it_should_validate_is_accepted :terms, :allow_nil => true
  #    it_should_validate_is_accepted :more_license, :allow_nil => false
  #  end
  #
  def it_should_validate_is_accepted( attribute, options={} )
    builder = DmSkinnySpec::Validations::ItShouldValidateIsAccepted
    builder.create_expectations_for attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def create_expectations
        @message   ||= '%s is not accepted'.t(@attribute_name)
        error_values = @options.delete(:reject) || [ '0', 0, false, 'false', 'f' ]

        if @allow_nil
          create_expectations_for_values nil, :type => :ok
        else
          error_values << nil
        end

        create_expectations_for_values error_values
      end

  end

end
