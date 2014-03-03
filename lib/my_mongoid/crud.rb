require "active_support/inflector"

module MyMongoid

  module CRUD
    extend ActiveSupport::Concern

    def collection
      self.class.collection
    end

    def save
      self.id = BSON::ObjectId.new unless self.id
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

      def create(attrs = {})
        doc = new(attrs)
        doc.save
        doc
      end

      def count
        self.collection.find.to_a.count
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