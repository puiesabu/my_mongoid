module MyMongoid

  module Document

    module ClassMethods

    	#
    	# Check if it is a MyMongoid model
    	#
      def is_mongoid_model?
        true
      end
    end
  end
end
