
class TestCallback
  include MyMongoid::Document

  field :number

  before_save :before_save_callback
  around_save :around_save_callback
  after_save :after_save_callback
  before_create :before_crud_callback
  around_create :around_crud_callback
  after_create :after_crud_callback
  before_update :before_crud_callback
  around_update :around_crud_callback
  after_update :after_crud_callback

  def before_save_callback
  end

  def around_save_callback
    yield self if block_given?
  end

  def after_save_callback
  end

  def before_crud_callback
  end

  def around_crud_callback
    yield self if block_given?
  end

  def after_crud_callback
  end
end

describe "Should define lifecycle callbacks" do
  describe "before, around, after hooks:" do
    it "should declare before hook for delete" do
      expect(TestCallback).to respond_to(:before_delete)
    end

    it "should declare around hook for delete" do
      expect(TestCallback).to respond_to(:around_delete)
    end

    it "should declare after hook for delete" do
      expect(TestCallback).to respond_to(:after_delete)
    end

    it "should declare before hook for save" do
      expect(TestCallback).to respond_to(:before_save)
    end

    it "should declare around hook for save" do
      expect(TestCallback).to respond_to(:around_save)
    end

    it "should declare after hook for save" do
      expect(TestCallback).to respond_to(:after_save)
    end

    it "should declare before hook for create" do
      expect(TestCallback).to respond_to(:before_create)
    end

    it "should declare around hook for create" do
      expect(TestCallback).to respond_to(:around_create)
    end

    it "should declare after hook for create" do
      expect(TestCallback).to respond_to(:after_create)
    end

    it "should declare before hook for update" do
      expect(TestCallback).to respond_to(:before_update)
    end

    it "should declare around hook for update" do
      expect(TestCallback).to respond_to(:around_update)
    end

    it "should declare after hook for update" do
      expect(TestCallback).to respond_to(:after_update)
    end
  end

  describe "only before hooks:" do
    it "should not declare before hook for find" do
      expect(TestCallback).to_not respond_to(:before_find)
    end

    it "should not declare around hook for find" do
      expect(TestCallback).to_not respond_to(:around_find)
    end

    it "should declare after hook for find" do
      expect(TestCallback).to respond_to(:after_find)
    end

    it "should not declare before hook for initialize" do
      expect(TestCallback).to_not respond_to(:before_initialize)
    end

    it "should not declare around hook for initialize" do
      expect(TestCallback).to_not respond_to(:around_initialize)
    end

    it "should declare after hook for initialize" do
      expect(TestCallback).to respond_to(:after_initialize)
    end

  end

  let(:test1) {
    TestCallback.new({:_id => 1})
  }

  let(:test2) {
    TestCallback.find({:_id => 2})
  }

  describe "run create callbacks" do
    it "should run callbacks when saving a new record" do
      expect(test1).to receive(:before_crud_callback)
      expect(test1).to receive(:around_crud_callback)
      expect(test1).to receive(:after_crud_callback)
      test1.save
    end
    
    it "should run callbacks when creating a new record" do
      expect_any_instance_of(TestCallback).to receive(:before_crud_callback)
      expect_any_instance_of(TestCallback).to receive(:around_crud_callback)
      expect_any_instance_of(TestCallback).to receive(:after_crud_callback)
      TestCallback.create({:_id => 1})
    end
  end

  describe "run save callbacks" do
    it "should run callbacks when saving a new record" do
      expect(test1).to receive(:before_save_callback)
      expect(test1).to receive(:around_save_callback)
      expect(test1).to receive(:after_save_callback)
      test1.save
    end

    it "should run callbacks when saving a persisted record" do
      TestCallback.create({:_id => 2})
      expect(test2).to receive(:before_save_callback)
      expect(test2).to receive(:around_save_callback)
      expect(test2).to receive(:after_save_callback)
      test2.save
    end
  end

  describe "run update callbacks" do
    it "should run callbacks when updaing a record" do
      TestCallback.create({:_id => 2})
      test2.number = 2
      expect(test2).to receive(:before_crud_callback)
      expect(test2).to receive(:around_crud_callback)
      expect(test2).to receive(:after_crud_callback)
      test2.save
    end
  end
end
