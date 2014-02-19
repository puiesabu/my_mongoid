require "my_mongoid/attributes/processing"

module MyMongoid

  module Attributes
    include Processing

    attr_reader :attributes

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
    #
    # @since 0.0.1
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
    #
    # @since 1.0.0
    def write_attribute(name, value)
      attributes[name] = value
    end    
  end
end