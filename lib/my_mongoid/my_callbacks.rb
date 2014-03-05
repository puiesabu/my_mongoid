module MyMongoid

  module MyCallbacks
    extend ActiveSupport::Concern

    class Callback
      attr_accessor :kind, :filter

      def initialize(filter, kind)
        @kind    = kind
        @filter  = filter
      end

      def invoke(target)
        target.send filter
      end
    end

    class CallbackChain
      def initialize(name = nil)
        @name = name
        @chain ||= []
      end

      def empty?
        @chain.empty?
      end

      def chain
        @chain
      end

      def append(callback)
        @chain << callback
      end

      def invoke(target, &block)
        chain.each do |callback|
          callback.invoke(target)
        end
        block.call
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
