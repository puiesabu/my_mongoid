# spec/my_mongoid/field_spec.rb
describe MyMongoid::Field do
  it "is a module" do
    expect(MyMongoid::Field).to be_a(Module)
  end

  describe ".new" do
    it "can be created with only name argrument" do
    	expect(described_class.new("field1")).to be_a(MyMongoid::Field)
    end

    it "can be created with options" do
    	expect(described_class.new("field2", {:as => "abc"})).to be_a(MyMongoid::Field)
    end

    it "raise ArgrumentError if name is not provided" do
    	expect{
    		described_class.new()
    	}.to raise_error(ArgumentError)
    end
  end
end

describe MyMongoid::Fields do
  it "automatically declares the '_id' field"  do
    expect(Event.fields.keys).to include("_id")
  end

  describe "#fields" do
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

  let(:attrs) {
    {"public" => true, "created_at" => Time.parse("2014-02-13T03:20:37Z")}
  }

  let(:event) {
    Event.new(attrs)
  }

  describe "#field" do
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

    it "raises MyMongoid::DuplicateFieldError if field is declared twice" do
      expect {
        Event.module_eval do
          field :public
        end
      }.to raise_error(MyMongoid::DuplicateFieldError)
    end
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

