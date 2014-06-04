describe Noam::Message do
  describe "::encode_length" do
    it "expands the length out to 6 digits" do
      Noam::Message.encode_length(6).should == "000006"
      Noam::Message.encode_length(123456).should == "123456"
    end
  end
end
