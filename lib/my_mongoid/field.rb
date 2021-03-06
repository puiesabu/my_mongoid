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
      class_attribute :fields
      class_attribute :aliased_fields
      class_attribute :defaulted_fields

      self.fields ||= {}
      self.aliased_fields ||= {}
      self.defaulted_fields ||= []

      field :_id, :as => :id
    end

    def apply_defaults
      defaulted_fields.each do |name|
        apply_default(name)
      end
    end

    def apply_default(name)
      unless attributes.has_key?(name)
        field = fields[name]
        if default = field.options[:default]
          write_attribute(name, default)
        end
      end
    end

    def validate_field(name, value)
      raise UnknownAttributeError, "Field :#{name} is not defined" unless self.class.has_field?(name)
      if type = fields[name].options[:type]
        raise InvalidFieldTypeError, "Field :#{name} type mismatches" unless value.class == type
      end
    end

    def attribute_changed?(name)
      return false unless changed_attributes.has_key?(name)
      changed_attributes[name] != attributes[name]
    end

    module ClassMethods
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
        add_field(field_name, field_name)

        options.each_pair do |key, value|
          case key
          when :as
            field_alias = options[:as].to_s
            add_field(field_name, field_alias)

            aliased_fields[field_alias] = field_name
          when :default
            defaulted_fields << field_name
          end
        end

        field = Field.new(field_name, options)
        fields[field_name] = field
      end

      def add_field(name, meth)
        raise DuplicateFieldError, "Field :#{meth} is duplicated" if has_field?(meth)
        create_getter(name, meth)
        create_setter(name, meth)
        create_dirty_change_check(name, meth)
        create_dirty_change_accessor(name, meth)
        create_dirty_previous_value_accessor(name, meth)
        create_dirty_reset(name, meth)
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

      def create_dirty_change_check(name, meth)
        define_method("#{meth}_changed?") do
          attribute_changed?(name)
        end
      end

      def create_dirty_change_accessor(name, meth)
        define_method("#{meth}_change") do
          [changed_attributes[name], attributes[name]] if attribute_changed?(name)
        end
      end

      def create_dirty_previous_value_accessor(name, meth)
        define_method("#{meth}_was") do
          attribute_changed?(name) ? changed_attributes[name] : attributes[name]
        end
      end

      def create_dirty_reset(name, meth)
        define_method("#{meth}_reset") do
          write_attribute(name, changed_attributes[name]) if attribute_changed?(name)
        end
      end
    end
  end
end
