require "spec_helper"
require "pry"

class Crud
  include MyMongoid::Document
  field :number, :as => :n
end

# Tranucate table
Crud.collection.find.remove_all

describe MyMongoid::CRUD do
  describe "#save" do
    let(:c1) {
      Crud.new({:id => 1, :n => 11})
    }

    it "document value should be the same as attributes" do
      c1.save
      f1 = Crud.find(1)
      expect(f1.id).to eq(c1.id)
      expect(f1.number).to eq(c1.number)
    end

    context "when saving a new record" do
      let(:c2) {
        Crud.new({:id => 2, :n => 12})
      }

      it "is new_record before saving" do
        expect(c2.new_record?).to eq(true)
      end

      it "is not new_record after saving" do
        c2.save
        expect(c2.new_record?).to eq(false)
      end

      let(:c3) {
        Crud.new({:id => 3, :n => 13})
      }

      it "collection size increased by 1" do
        count = Crud.count
        c3.save
        expect(Crud.count).to eq(count + 1)
      end
    end

    context "when saving and existing record" do
      it "collection size remain the same" do
        count = Crud.count
        c = Crud.find(3)
        c.save
        expect(Crud.count).to eq(count)
      end
    end
  end

  describe "#delete" do
    it "collection size decreased by 1" do
      count = Crud.count
      c = Crud.find(3)
      c.delete
      expect(Crud.count).to eq(count - 1)
    end

    it "cannot be found after delete" do
      expect(Crud.find(3)).to eq(nil)
    end
  end

  describe "#create" do
    it "cannot be found before create" do
      expect(Crud.find(4)).to eq(nil)
    end

    it "can be found after create" do
      Crud.create({:id => 4, :n => 14})
      expect(Crud.find(4)).to_not eq(nil)
    end

    it "collection size increased by 1"do
      count = Crud.count
      Crud.create({:id => 5, :n => 15})
      expect(Crud.count).to eq(count + 1)
    end
  end

  describe "#count" do
    it "returns the collection size" do
      expect(Crud.count).to eq(Crud.collection.find.to_a.size)
    end
  end

  describe "#find" do
    let(:id) {
      5
    }

    let(:c5) {
      Crud.find(id)
    }

    it "returns the saved document in MyMongoid model" do
      expect(c5.is_mongoid_model?).to eq(true)
    end
 
    it "id is the same as the input" do
      expect(c5.id).to eq(id)
    end
  end
end