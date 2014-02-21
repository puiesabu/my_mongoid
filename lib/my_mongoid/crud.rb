module MyMongoid

  module CRUD
    extend ActiveSupport::Concern

    def collection
      self.class.collection
    end

    def selector
      @selector ||= {}
      self.class.fields.keys.each do |field|
        @selector[field.to_s] = send(field)
      end
      @selector
    end

    def save
      collection.find({"_id" => _id}).update(attributes)
      true
    end

    def insert_as_root
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
        document ? doc = new(document) : nil
      end
    end
  end
end