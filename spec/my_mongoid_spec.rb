describe MyMongoid do

	class M
		include MyMongoid::Document
	end

	describe "#models" do
		it "maintains a list of models" do
      expect(MyMongoid.models).to include(M)
    end
	end
end