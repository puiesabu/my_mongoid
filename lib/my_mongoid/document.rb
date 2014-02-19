require "my_mongoid/document/class_methods"
require "my_mongoid/attributes"
require "my_mongoid/fields"

require "pry"

module MyMongoid

	module Document
    include ClassMethods
    include Attributes
    include Fields
    #include Composable

    attr_accessor :__selected_fields

    def self.included(base)
      #binding.pry
      MyMongoid.register_model(base)
      base.extend(ClassMethods)
    end

    def is_mongoid_model?
    	self.class.is_mongoid_model?
    end

    # Instantiate a new +Document+, setting the Document's attributes if
    # given. If no attributes are provided, they will be initialized with
    # an empty +Hash+.
    #
    # If a primary key is defined, the document's id will be set to that key,
    # otherwise it will be set to a fresh +BSON::ObjectId+ string.
    #
    # @example Create a new document.
    #   Person.new(:title => "Sir")
    #
    # @param [ Hash ] attrs The attributes to set up the document with.
    #
    # @return [ Document ] A new document.
    #
    # @since 1.0.0
    def initialize(attrs = nil)
      attrs ||= {}
      unless attrs.is_a?(Hash)
        raise ArgumentError, "Hash object argument is expected for #new"
      end

      #@new_record = true
      #@attributes ||= {}
      @attributes = attrs
      #with(self.class.persistence_options)
      #apply_pre_processed_defaults
      #apply_default_scoping
      #process_attributes(attrs) do
      #  yield(self) if block_given?
      #end
      #apply_post_processed_defaults
      # @todo: #2586: Need to have access to parent document in these
      #   callbacks.
      #run_callbacks(:initialize) unless _initialize_callbacks.empty?
    end
	end
end
