module MyMongoid
  module Document

    module ClassMethods

    	# Check if it is a MyMongoid model
      def is_mongoid_model?
        true
      end

      # @return [ Hash ] A hash of fields
      def fields
        @fields
      end

      # Declare a field with the DSL
      #
      # @example Define a field.
      #   field :age
      #
      # @param [ Symbol ] name The name of the field.
      def field(name)
        @fields ||= {}
        field_name = name.to_s
        raise DuplicateFieldError if @fields.has_key?(field_name)

        field = Field.new(field_name)
        @fields[field_name] = field

        create_getter(field_name)
        create_setter(field_name)
      end

      # Create the getter method for the provided field.
      #
      # @example Create the getter.
      #   Model.create_getter("age")
      #
      # @param [ String ] name The name of the attribute.
      def create_getter(name)
        define_method(name) do
          instance_variable_get("@#{name}")
        end
      end

      # Create the setter method for the provided field.
      #
      # @example Create the setter.
      #   Model.create_setter("age")
      #
      # @param [ String ] name The name of the attribute.
      def create_setter(name)
        define_method("#{name}=") do |value|
          write_attribute(name, value)
          instance_variable_set("@#{name}", value)
        end
      end
    end
  end
end
