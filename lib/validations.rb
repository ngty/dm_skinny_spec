require 'validations/common'
require 'validations/it_should_validate_absent'
require 'validations/it_should_validate_format'
require 'validations/it_should_validate_is_accepted'
require 'validations/it_should_validate_is_confirmed'
require 'validations/it_should_validate_is_unique'
require 'validations/it_should_validate_length'
require 'validations/it_should_validate_present'

module DmSkinnySpec::Validations

  class << self

    def init
      if has_prerequisites?
        builders.each { |builder| enhance_spec_example_group(builder) }
      end
    end

    private

      def enhance_spec_example_group(builder)
        Spec::Example::ExampleGroup.extend(builder)
      end

      def has_prerequisites?
        Object.const_defined?('DataMapper') && DataMapper.const_defined?('Validate')
      end

      def builder_files
        Dir.glob( 
          File.join(File.dirname(File.expand_path(__FILE__)),'validations') +
            '/it_should_validate_*.rb' 
          ) 
      end

      def builders
        builder_files.map do |file|
          Extlib::Inflection.constantize(
            self.to_s + '::' + 
              Extlib::Inflection.classify(File.basename(file,'.rb'))
            )
        end
      end

  end

end

DmSkinnySpec::Validations.init
