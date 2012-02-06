module Samurai
  module ActiveResourceSupport

    def self.included(base)
      if [ActiveResource::VERSION::MAJOR, ActiveResource::VERSION::MINOR].compact.join('.').to_f < 3.0
        # If we're using ActiveResource pre-3.1, there's no schema class method, so we resort to some tricks...
        # Initialize the known attributes from the schema as empty strings, so that they can be accessed via method-missing
        base.const_set 'EMPTY_ATTRIBUTES', base.const_get('KNOWN_ATTRIBUTES').inject(HashWithIndifferentAccess.new) {|h, k| h[k] = ''; h}

        base.class_eval do
          # Modify the constructor to emulate the schema behavior
          def initialize(attrs={})
            _empty_attributes = self.class.const_get('EMPTY_ATTRIBUTES')
            super(_empty_attributes.merge(attrs))
          end

          # Add missing #update_attributes
          def update_attributes(attributes)
            load(attributes) && save
          end
        end

      else
        # Post AR 3.1, we can use the schema method to define our attributes
        base.schema { string *base.const_get('KNOWN_ATTRIBUTES') }
      end
    end

  end
end
