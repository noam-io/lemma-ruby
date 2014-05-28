describe Noam::Message::Register do
  describe "#new" do
    it "creates a new Register object" do
      Noam::Message::Register.new(
        :devid, :port, :hears, :speaks, :type
      ).class.should == Noam::Message::Register
    end
  end

  describe "#noam_encode" do
    it "encodes the Register message" do
      Noam::Message::Register.new(
        "an_id", 1234, ["e1"], ["e2", "e3"], "thingy"
      ).noam_encode.should == '000061["register","an_id",1234,["e1"],["e2","e3"],"thingy","'+NOAM_SYS_VERSION+'"]'
    end
  end
end
