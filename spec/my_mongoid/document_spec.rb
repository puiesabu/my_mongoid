require "spec_helper"

class Event
  include MyMongoid::Document
  field :_type, :as => :type
  field :public
  field :created_at
end

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

  describe "#fields" do
    it "maintains a list of fields for a model" do
      expect(Event.fields.keys).to include("public")
    end
  end

  describe "#aliased_fields" do
    let (:aliased_fields) {
      Event.aliased_fields.keys
    }

    it "maintains a list of alias for fields" do
      expect(aliased_fields).to include("type")
    end

    it "does not have field without alias" do
      expect(aliased_fields).to_not include("public")
    end
  end

  describe "#original_name" do
    context "when the field does not have alias" do
      it "return the same field name" do
        expect(Event.original_name("public")).to eq("public")
      end
    end 

    context "when the field has alias" do
      it "return the original field name" do
        expect(Event.original_name("type")).to eq("_type")
      end
    end
  end

  describe "#has_field" do
    it "is true when field is declared with field name provided" do
      expect(Event.has_field?("_type")).to eq(true)
    end

    it "is true when field is declared with alias provided" do
      expect(Event.has_field?("type")).to eq(true)
    end

    it "is false when no field declared for the provided field name" do
      expect(Event.has_field?("abc")).to eq(false)
    end
  end
end

describe "Declare fields:" do
  let(:attrs) {
    {"public" => true, "created_at" => Time.parse("2014-02-13T03:20:37Z")}
  }

  let(:event) {
    Event.new(attrs)
  }

  it "can declare a field using the 'field' DSL" do
    expect(Event).to be_a(Class)
  end

  it "declares getter for a field" do
    expect(event).to respond_to(:public)
    expect(event.public).to eq(attrs["public"])
  end

  it "declares setter for a field" do
    expect(event).to respond_to(:public=)
    event.public = false
    expect(event.public).to eq(false)
    expect(event.read_attribute("public")).to eq(false)
  end

  context ".fields" do
    let(:fields) {
      Event.fields
    }
    it "maintains a map fields objects" do
      expect(fields).to be_a(Hash)
      expect(fields.keys).to include(*%w(public created_at))
    end

    it "returns a string for Field#name" do
      field = fields["public"]
      expect(field).to be_a(MyMongoid::Field)
      expect(field.name).to eq("public")
    end
  end

  it "raises MyMongoid::DuplicateFieldError if field is declared twice" do
    expect {
      Event.module_eval do
        field :public
      end
    }.to raise_error(MyMongoid::DuplicateFieldError)
  end

  it "automatically declares the '_id' field"  do
    expect(Event.fields.keys).to include("_id")
  end
end

describe "Field options:" do
  let(:model) {
    Class.new do
      include MyMongoid::Document
      field :number, :as => :n
    end
  }

  it "accepts hash options for the field keyword" do
    expect {
      model
    }.to_not raise_error
  end

  it "stores the field options in Field object" do
    expect(model.fields["number"].options).to eq(:as => :n)
  end

  it "aliases a field with the :as option" do
    record = model.new(number: 10)
    expect(record.number).to eq(10)
    expect(record.n).to eq(10)
    record.n = 20
    expect(record.number).to eq(20)
    expect(record.n).to eq(20)
  end

  it "by default aliases '_id' as 'id'" do
    record = model.new({})
    record.id = "abc"
    expect(record._id).to eq("abc")
  end
end
