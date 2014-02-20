module MyMongoid

  module Attributes

    attr_reader :attributes

    # Set a batch of attributes
    #
    # @example Set attributes
    #   person.process_attributes(:title => "sir", :age => 40)
    #
    # @param [ Hash ] attrs The attributes to set.
    def process_attributes(attrs = nil)
      attrs ||= {} 
      attrs.each_pair do |key, value|
        name = key.to_s
        raise UnknownAttributeError, "Field :#{name} is not defined" unless self.class.has_field?(name)

        send("#{name}=", value)
      end
    end
    alias :attributes= :process_attributes

    # Read a value from the document attributes. If the value does not exist
    # it will return nil.
    #
    # @example Read an attribute.
    #   person.read_attribute(:title)
    #
    # @example Read an attribute (alternate syntax.)
    #   person[:title]
    #
    # @param [ String ] name The name of the attribute to get.
    #
    # @return [ Object ] The value of the attribute.
    def read_attribute(name)
      field_name = self.class.original_name(name)
      attributes[field_name]
    end

    # Write a single attribute to the document attribute hash. 
    #
    # @example Write the attribute.
    #   person.write_attribute(:title, "Mr.")
    #
    # @example Write the attribute (alternate syntax.)
    #   person[:title] = "Mr."
    #
    # @param [ String ] name The name of the attribute to update.
    # @param [ Object ] value The value to set for the attribute.
    def write_attribute(name, value)
      field_name = self.class.original_name(name)
      attributes[field_name] = value
    end
  end
end
