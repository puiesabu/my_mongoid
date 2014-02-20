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
