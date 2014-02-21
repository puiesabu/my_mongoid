module MyMongoid

  class Field
    attr_accessor :name, :options

    def initialize(name, options = {})
      @name = name
      @options = options
    end
  end

  module Fields
  	extend ActiveSupport::Concern

    included do
      field :_id, :as => :id
    end

    module ClassMethods
    	def fields
    		@fields
    	end

    	def aliased_fields
    		@aliased_fields
    	end 

      # @return [ String ] The original field names if alias is provided
      def original_name(name)
        aliased_fields[name] || name
      end

      # Check if name has already been used for field or alias 
      def has_field?(name)
        aliased_fields.has_key?(name) || fields.has_key?(name)
      end

      # Declare a field with the DSL
      #
      # @example Define a field.
      #   field :age
      #
      # @param [ Symbol ] name The name of the field.
      def field(name, options = {})
        @fields ||= {}
        @aliased_fields ||= {}

        field_name = name.to_s
        raise DuplicateFieldError, "Field :#{field_name} is duplicated" if has_field?(field_name)
        create_getter(field_name, field_name)
        create_setter(field_name, field_name)

        options.each_pair do |key, value|
          case key
          when :as
            field_alias = options[:as].to_s
            raise DuplicateFieldError, "Field :#{field_alias} is duplicated" if has_field?(field_alias)
            create_getter(field_name, field_alias)
            create_setter(field_name, field_alias)

            aliased_fields[field_alias] = field_name
          when :default
            write_attribute(name, value)
          end
        end

        field = Field.new(field_name, options)
        fields[field_name] = field
      end

      # Create the getter method for the provided field.
      #
      # @example Create the getter.
      #   Model.create_getter("age")
      #
      # @param [ String ] name The name of the attribute.
      def create_getter(name, meth)
        define_method(meth) do
          read_attribute(name)
        end
      end

      # Create the setter method for the provided field.
      #
      # @example Create the setter.
      #   Model.create_setter("age")
      #
      # @param [ String ] name The name of the attribute.
      def create_setter(name, meth)
        define_method("#{meth}=") do |value|
          write_attribute(name, value)
        end
      end
    end
  end
end
