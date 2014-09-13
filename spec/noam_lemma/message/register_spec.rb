describe Noam::Message::Register do
  describe "#new" do
    it "creates a new Register object" do
      message = Noam::Message::Register.new(:devid, :port, :hears, :speaks)
      expect(message).to be_a(Noam::Message::Register)
    end
  end

  describe "#noam_encode" do
    it "encodes the Register message" do
      encoded_message = Noam::Message::Register.new("an_id", 1234, ["e1"], ["e2", "e3"]).noam_encode
      expected_message = <<-MESSAGE.gsub(/^\s+|\n/, "")
        000066["register","an_id",1234,["e1"],["e2","e3"],"#{Noam::DEVICE_TYPE}","#{Noam::VERSION}"]
      MESSAGE

      expect(encoded_message).to eq(expected_message)
    end
  end
end
