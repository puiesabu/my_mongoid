require "spec_helper"

class Attr
  include MyMongoid::Document
  field :age
end

describe "MyMongoid::Attributes" do
  let(:attributes) {
    {"age" => 18}
  }

  let(:a) {
    Attr.new(attributes)
  }

  it "can read the attributes of model" do
    expect(a.attributes).to include(attributes)
  end

  describe "#read_attribute" do
    it "can get an attribute with #read_attribute" do
      expect(a.read_attribute("age")).to eq(18)
    end

    it "has the same value of getter" do
      expect(a.read_attribute("age")).to eq(a.age)
    end
  end

  describe "#write_attribute" do
    it "can set an attribute with #write_attribute" do
      a.write_attribute("age", 22)
      expect(a.read_attribute("age")).to eq(22)
    end
  end

  describe "#process_attributes" do
    class FooModel
      include MyMongoid::Document
      field :number
      def number=(n)
        self.attributes["number"] = n + 1
      end
    end

    let(:foo) {
      FooModel.new({})
    }

    it "use field setters for mass-assignment" do
      foo.process_attributes :number => 10
      expect(foo.number).to eq(11)
    end

    it "raise MyMongoid::UnknownAttributeError if the attributes Hash contains undeclared fields." do
      expect {
        foo.process_attributes :unkonwn => 10
      }.to raise_error(MyMongoid::UnknownAttributeError)
    end

    it "aliases #process_attributes as #attribute=" do
      foo.attributes = {:number => 10}
      expect(foo.number).to eq(11)
    end

    it "uses #process_attributes for #initialize" do
      foo = FooModel.new({:number => 10})
      expect(foo.number).to eq(11)
    end
  end
end
