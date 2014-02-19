require "my_mongoid/document/class_methods"
require "my_mongoid/attributes"
require "my_mongoid/field"
require "my_mongoid/duplicate_field_error"

module MyMongoid

  module Document
    include ClassMethods
    include Attributes

    def self.included(base)
      MyMongoid.register_model(base)
      base.extend(ClassMethods)
      base.class_eval do
        field :_id
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
      unless attrs.is_a?(Hash)
        raise ArgumentError, "Hash object argument is expected for #new"
      end

      @new_record = true
      @attributes = attrs
      set_attributes(attrs)
    end
  end
end
