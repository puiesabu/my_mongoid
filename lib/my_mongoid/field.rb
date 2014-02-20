module MyMongoid

  class Field
    attr_accessor :name, :options

    def initialize(name, options = {})
      @name = name
      @options = options
    end
  end
end
