require "my_mongoid/document/class_methods"
require "my_mongoid/attributes"

module MyMongoid

  module Document
    include ClassMethods
    include Attributes

    def self.included(base)
      MyMongoid.register_model(base)
      base.extend(ClassMethods)
    end

    #
    # Check if it is a MyMongoid model
    #
    def is_mongoid_model?
      self.class.is_mongoid_model?
    end

    #
    # Check if it is a newly initialized record
    #
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
    #
    # @since 0.0.1
    def initialize(attrs = nil)
      attrs ||= {}
      unless attrs.is_a?(Hash)
        raise ArgumentError, "Hash object argument is expected for #new"
      end

      @new_record = true
      @attributes = attrs
    end
  end
end
