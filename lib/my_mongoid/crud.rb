require "active_support/inflector"

module MyMongoid

  module CRUD
    extend ActiveSupport::Concern

    def collection
      self.class.collection
    end

    def save
      collection.insert(self.to_document)
      self.new_record = false
      true
    end

    def delete
      collection.find({"_id" => _id}).remove
      true
    end

    module ClassMethods
      def collection_name
        self.name.tableize
      end

      def collection
        MyMongoid.session[collection_name]
      end

      def create attrs = {}
        doc = new(attrs)
        doc.save
        doc
      end

      def count
        self.collection.find.to_a.count
      end

      def find(target_id)
        document = collection.find({"_id" => target_id}).to_a.first
        if document 
          doc = new(document)
          doc.new_record = false
          doc
        else
          nil
        end
      end
    end
  end
end