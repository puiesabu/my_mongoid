require "active_support/concern"
require "my_mongoid/attributes"
require "my_mongoid/error"
require "my_mongoid/field"
require "my_mongoid/crud"
require "my_mongoid/my_callbacks"

module MyMongoid

  module Document
    extend ActiveSupport::Concern
    include Attributes
    include Fields
    include CRUD

    attr_accessor :new_record

    included do
      MyMongoid.register_model(self)
    end

    # Check if it is a MyMongoid model
    def is_mongoid_model?
      self.class.is_mongoid_model?
    end

    # Check if it is a newly initialized record
    def new_record?
      @new_record
    end

    def to_document
      attributes
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
      apply_defaults
      self.id = BSON::ObjectId.new unless self.id
    end

    module ClassMethods
      def instantiate attrs = nil
        attributes = attrs || {}
        doc = allocate
        doc.instance_variable_set(:@attributes, attributes)
        doc.new_record = false
        doc.run_callbacks(:find)
        doc
      end

      # Check if it is a MyMongoid model
      def is_mongoid_model?
        true
      end
    end
  end
end
