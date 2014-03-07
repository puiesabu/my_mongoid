module MyMongoid

  module MyCallbacks
    extend ActiveSupport::Concern

    class Callback
      attr_accessor :kind, :filter

      def initialize(filter, kind)
        @kind = kind
        @filter = filter
      end

      def invoke(target, &block)
        target.send filter, &block
      end

      def compile
        lambda { |target, &block|
          target.send filter, &block
        }
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
        _invoke(0, target, block)
      end

      def _invoke(i, target, block)
        if i == chain.length
          block.call
        else
          callback = chain[i]

          case callback.kind
          when :before
            callback.invoke(target)
            _invoke(i+1, target, block)
          when :after
            _invoke(i+1, target, block)
            callback.invoke(target)
          when :around
            callback.invoke(target) do
              _invoke(i+1, target, block)
            end
          end
         end
      end
    end

    def run_callbacks(name, &block)
      cbs = send("_#{name}_callbacks")
      if cbs.empty?
        yield if block_given?
      else
        cbs.invoke(self, &block)
      end
    end
    
    module ClassMethods
      def set_callback(name, kind, filter)
        get_callbacks(name).append(Callback.new(filter, kind))
      end

      def define_callbacks(*names)
        names.each do |name|
          class_attribute "_#{name}_callbacks"
          set_callbacks name, CallbackChain.new(name)
        end
      end

      def set_callbacks(name, callbacks)
        send "_#{name}_callbacks=", callbacks
      end

      def get_callbacks(name)
        send "_#{name}_callbacks"
      end
    end
  end
end
