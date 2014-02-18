require "my_mongoid/document/class_methods"

module MyMongoid
	module Document
		include ClassMethods

    def self.included(base)
      MyMongoid.register_model(base)
      base.extend(ClassMethods)
    end

    def is_mongoid_model?
    	self.class.is_mongoid_model?
    end
	end
end
