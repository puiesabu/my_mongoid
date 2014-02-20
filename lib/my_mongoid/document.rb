require "my_mongoid/attributes"
require "my_mongoid/field"
require "my_mongoid/error"

module MyMongoid

  module Document
    include Attributes

    def self.included(base)
      MyMongoid.register_model(base)
      base.extend(ClassMethods)
      base.class_eval do
        field :_id, :as => :id
      end
    end

    # Check if it is a MyMongoid model
    def is_mongoid_model?
      self.class.is_mongoid_model?
    end

    # Check if it is a newly initialized record
    def new_record?
      @new_record
    end

    # Instantiate a new Document
    #
    # @example Create a new document.
    #   Person.new(:title => "Sir")
    #
    # @param [ Hash ] attrs The attributes to set up the document with.
    #
    # @return [ Document ] A new document.
    def initialize(attrs = nil)
      attrs ||= {}
      raise ArgumentError, "Hash object is expected" unless attrs.is_a?(Hash)

      @new_record = true
      @attributes ||= {}
      process_attributes(attrs)
    end

    module ClassMethods

      # Check if it is a MyMongoid model
      def is_mongoid_model?
        true
      end

        # @return [ Hash ] A hash of fields
        def fields
          @fields
        end

        # @return [ Hash ] A hash of field names for fields which has alias
        def aliased_fields
          @aliased_fields
        end

        # @return [ String ] The original field names if alias is provided
        def original_name(name)
          @aliased_fields[name] || name
        end

        # Check if name has already been used for field or alias 
        def has_field?(name)
          @aliased_fields.has_key?(name) || @fields.has_key?(name)
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

              @aliased_fields[field_alias] = field_name
            when :default
              write_attribute(name, value)
            end
          end

          field = Field.new(field_name, options)
          @fields[field_name] = field
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
