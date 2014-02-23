module MyMongoid

  module CRUD
    extend ActiveSupport::Concern

    def collection
      self.class.collection
    end

    def save
      if self.new_record?
        insert_as_root
      else
        collection.find({"_id" => _id}).update(attributes)
      end
      true
    end

    def insert_as_root
      self.new_record = false
      collection.insert(attributes)
    end

    def delete
      collection.find({"_id" => _id}).remove
      true
    end

    module ClassMethods
      def collection
        MyMongoid.default_session[self.inspect]
      end

      def create(attr = nil, &block)
        doc = new(attr, &block)
        doc.insert_as_root
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