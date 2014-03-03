require "spec_helper"

describe MyMongoid::Document do
  it "is a module" do
    expect(MyMongoid::Document).to be_a(Module)
  end

  it "creates MyMongoid::Document::ClassMethods" do
    expect(MyMongoid::Document::ClassMethods).to be_a(Module)
  end

  describe ".included" do
    let(:models) do
      MyMongoid.models
    end

    let(:new_klass_name) do
      'NewKlassName'
    end

    let(:new_klass) do
      Class.new do
        class << self; attr_accessor :name; end
      end.tap{|new_klass| new_klass.name = new_klass_name}
    end

    let(:new_model) do
      new_klass.tap do
        new_klass.send(:include, ::MyMongoid::Document)
      end
    end

    context "when Document has been included in a model" do
      it ".models should include that model" do
        expect(models).to include(Event)
      end
    end

    context "before Document has been included" do
      it ".models should *not* include that model" do
        expect(models).to_not include(new_klass)
      end
    end

    context "after Document has been included" do
      it ".models should include that model" do
        expect(models).to include(new_model)
      end
    end
  end

  describe "#is_mongoid_model?" do
    it "return true when it is a mongoid model" do
      expect(Event.is_mongoid_model?).to eq(true)
    end
  end

  let(:attrs) {
    {"public" => true, "created_at" => Time.parse("2014-02-13T03:20:37Z")}
  }

  let(:event) {
    Event.new(attrs)
  }

  describe ".new" do
	  it "throws an error if attributes it not a Hash" do
	    expect {
	      Event.new(100)
	    }.to raise_error(ArgumentError)
	  end

	  it "can instantiate a model with attributes" do
	    expect(event).to be_an(Event)
	  end

	  it "is a new record initially" do
	    expect(event).to be_new_record
	  end
  end
end
