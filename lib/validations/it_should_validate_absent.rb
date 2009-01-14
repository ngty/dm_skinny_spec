module DmSkinnySpec::Validations::ItShouldValidateAbsent
  
  ###
  # Creates expectations for verifying that +attribute+ is blank. 
  #
  # Supported options are:
  # * :boolean ... specify that the attribute is a boolean, default is false
  # * :message ... customize the expected error message (optional)
  # * :when    ... context in which the validation applies (optional)
  # 
  # Notes:
  # * you have to provide an instance() method in your specs to return valid
  #   instances of your model (see the example below).
  # 
  # Examples:
  #
  #   class Page
  #     include DataMapper::Resource
  #  
  #     property :id,              Serial
  #     property :first_unwanted,  String,  :auto_validation => false
  #     property :second_unwanted, String,  :auto_validation => false
  #     property :is_unwanted,     Boolean, :auto_validation => false
  #  
  #     validates_absent :first_unwanted,  :when    => :first_unwanted_test
  #     validates_absent :second_unwanted, :message => "We don't want 2nd unwanted"
  #     validates_absent :is_unwanted   
  #   end
  #  
  #   Page.fix {{ 
  #     :first_unwanted  => [ nil, '' ].pick,
  #     :second_unwanted => [ nil, '' ].pick,
  #     :is_unwanted     => [ nil, false ].pick
  #   }}
  #  
  #   describe Page do
  #  
  #     before do
  #       Page.auto_migrate!
  #       @instances = {}
  #     end
  #  
  #     def instance(id=:default)
  #       @instances[id] ||= Page.gen
  #     end
  #  
  #     it_should_validate_absent :first_unwanted,  :when => :first_unwanted_test
  #     it_should_validate_absent :second_unwanted, :message => "We don't want 2nd unwanted"
  #     it_should_validate_absent :is_unwanted,     :boolean => true
  #  
  #   end
  #
  def it_should_validate_absent( attribute, options={} )
    builder = DmSkinnySpec::Validations::ItShouldValidateAbsent
    builder.create_expectations_for attribute, options, self
  end

  class << self

    include DmSkinnySpec::Validations::Common

    private

      def create_expectations
        @message ||= '%s must be absent'.t(@attribute_name)

        case @options[:boolean]
          when true ; create_expectations_for_values true
          else      ; create_expectations_for_values 'x', :description => 'is not blank'
        end
      end

  end

end
