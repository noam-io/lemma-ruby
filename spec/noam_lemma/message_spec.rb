describe Noam::Message do
  describe "::encode_length" do
    it "expands the length out to 6 digits" do
      expect(Noam::Message.encode_length(6)).to eq("000006")
      expect(Noam::Message.encode_length(123456)).to eq("123456")
    end
  end
end
