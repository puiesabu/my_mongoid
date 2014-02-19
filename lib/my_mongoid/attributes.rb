module MyMongoid

  module Attributes

    attr_reader :attributes

    # Set a batch of attributes
    #
    # @example Set attributes
    #   person.set_attributes(:title => "sir", :age => 40)
    #
    # @param [ Hash ] attrs The attributes to set.
    def set_attributes(attrs = nil)
      attrs ||= {} 
      attrs.each_pair do |key, value|
        name = key.to_s
        send("#{name}=", value)
      end
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
    # @param [ String ] name The name of the attribute to get.
    #
    # @return [ Object ] The value of the attribute.
    def read_attribute(name)
      attributes[name]
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
      attributes[name] = value
    end
  end
end
