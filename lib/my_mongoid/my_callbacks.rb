module MyMongoid

  module MyCallbacks
    extend ActiveSupport::Concern
    
    class CallbackChain
      def initialize(name)
        @name = name
      end
    end

    module ClassMethods
      def define_callbacks(*names)
        names.each do |name|
          class_attribute "_#{name}_callbacks"
          set_callbacks name, CallbackChain.new(name)
        end
      end

      def set_callbacks(name, callbacks)
        send "_#{name}_callbacks=", callbacks
      end
    end
  end
end
