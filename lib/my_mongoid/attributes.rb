require "my_mongoid/attributes/processing"

module MyMongoid

	module Attributes
    include Processing

		attr_reader :attributes

    # Get the attributes that have not been cast.
    #
    # @example Get the attributes before type cast.
    #   document.attributes_before_type_cast
    #
    # @return [ Hash ] The uncast attributes.
    #
    # @since 3.1.0
    def attributes_before_type_cast
      @attributes_before_type_cast ||= {}
    end

		# Read a value from the document attributes. If the value does not exist
    # it will return nil.
    #
    # @example Read an attribute.
    #   person.read_attribute(:title)
    #
    # @example Read an attribute (alternate syntax.)
    #   person[:title]
    #
    # @param [ String, Symbol ] name The name of the attribute to get.
    #
    # @return [ Object ] The value of the attribute.
    #
    # @since 0.0.1
    def read_attribute(name)
      normalized = database_field_name(name.to_s)
      if attribute_missing?(name)
        raise ActiveModel::MissingAttributeError, "Missing attribute: '#{name}'."
      end
      if hash_dot_syntax?(normalized)
        attributes.__nested__(normalized)
      else
        attributes[normalized]
      end
    end

    # Write a single attribute to the document attribute hash. This will
    # also fire the before and after update callbacks, and perform any
    # necessary typecasting.
    #
    # @example Write the attribute.
    #   person.write_attribute(:title, "Mr.")
    #
    # @example Write the attribute (alternate syntax.)
    #   person[:title] = "Mr."
    #
    # @param [ String, Symbol ] name The name of the attribute to update.
    # @param [ Object ] value The value to set for the attribute.
    #
    # @since 1.0.0
    def write_attribute(name, value)
      access = database_field_name(name.to_s)
      #if attribute_writable?(access)
        validate_attribute_value(access, value)
        localized = fields[access].try(:localized?)
        attributes_before_type_cast[name.to_s] = value
        typed_value = typed_value_for(access, value)
        unless attributes[access] == typed_value || attribute_changed?(access)
          attribute_will_change!(access)
        end
        if localized
          (attributes[access] ||= {}).merge!(typed_value)
        else
          attributes[access] = typed_value
        end
        typed_value
      #end
    end    

    # Determine if the attribute is missing from the document, due to loading
    # it from the database with missing fields.
    #
    # @example Is the attribute missing?
    #   document.attribute_missing?("test")
    #
    # @param [ String ] name The name of the attribute.
    #
    # @return [ true, false ] If the attribute is missing.
    #
    # @since 4.0.0
    def attribute_missing?(name)
      selection = __selected_fields
      return false unless selection
      (selection.values.first == 0 && selection[name.to_s] == 0) ||
        (selection.values.first == 1 && !selection.has_key?(name.to_s))
    end    

    # Does the string contain dot syntax for accessing hashes?
    #
    # @api private
    #
    # @example Is the string in dot syntax.
    #   model.hash_dot_syntax?
    #
    # @return [ true, false ] If the string contains a "."
    #
    # @since 3.0.15
    def hash_dot_syntax?(string)
      string.include?(".")
    end

   # Validates an attribute value. This provides validation checking if
    # the value is valid for given a field.
    # For now, only Hash and Array fields are validated.
    #
    # @param [ String, Symbol ] name The name of the attribute to validate.
    # @param [ Object ] value The to be validated.
    #
    # @since 3.0.10
    def validate_attribute_value(access, value)
      return unless value
      #return unless fields[access] && value
      validatable_types = [ Hash, Array ]
      if validatable_types.include? fields[access].type
        unless value.is_a? fields[access].type
          raise Mongoid::Errors::InvalidValue.new(fields[access].type, value.class)
        end
      end
    end
  end
end