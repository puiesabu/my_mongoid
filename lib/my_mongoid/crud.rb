require "active_support/inflector"
require "active_model"

module MyMongoid

  module CRUD
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks
      include ActiveModel::Validations::Callbacks

      define_model_callbacks :delete, :save, :create, :update
      define_model_callbacks :find, :initialize, only: :after
    end

    def collection
      self.class.collection
    end

    def save
      run_callbacks(:save) do
        if new_record?
          run_callbacks(:create) do
            collection.insert(self.to_document)
            self.new_record = false
            self.changed_attributes.clear
          end
        else
          run_callbacks(:update) do
            update_document
          end
        end
        true
      end
    end

    def atomic_updates
      result ||= {}
      if !new_record? && changed?
        updates ||= {}
        changed_attributes.keys.each do |key|
          updates[key] = read_attribute(key)
        end
        result["$set"] = updates
      end
      result
    end

    def update_document
      # get the field changes
      updates = atomic_updates

      # make the update query
      unless updates.empty?
        selector = { "_id" => self.id }
        self.class.collection.find(selector).update(updates)
      end
    end

    def delete
      self.class.collection.find({"_id" => self.id}).remove
      @deleted = true
    end

    def deleted?
      @deleted ||= false
    end

    def reload
      result = self.class.collection.find({"_id" => self.id}).to_a
      raise RecordNotFoundError if result.empty?
      process_attributes(result.first)
    end

    module ClassMethods
      def collection_name
        self.to_s.tableize
      end

      def collection
        MyMongoid.session[collection_name.to_sym]
      end

      def create(attrs = {})
        doc = new(attrs)
        doc.save
        doc
      end

      def find(attrs)
        case attrs 
        when Hash
          selector = create_selector(attrs)
        when String
          selector = create_selector({"_id" => attrs})
        when Fixnum
          selector = create_selector({"_id" => attrs})
        end

        result = collection.find(selector).to_a
        raise RecordNotFoundError if result.empty?
        instantiate(result.first)
      end

      def create_selector(attrs)
        selector ||= {}
        attrs.each_pair do |key, value|
          field = aliased_fields[key.to_s] || key.to_s
          selector[field] = value
        end
        selector
      end
    end
  end
end
