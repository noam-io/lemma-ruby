describe Noam::Message::Register do
  describe "#new" do
    it "creates a new Register object" do
      message = Noam::Message::Register.new(:devid, :port, :hears, :speaks)
      message.should be_a(Noam::Message::Register)
    end
  end

  describe "#noam_encode" do
    it "encodes the Register message" do
      message = Noam::Message::Register.new("an_id", 1234, ["e1"], ["e2", "e3"]).noam_encode
      expected = '000066["register","an_id",1234,["e1"],["e2","e3"],"' +
        Noam::DEVICE_TYPE + '","' + Noam::VERSION + '"]'
      message.should == expected
    end
  end
end
