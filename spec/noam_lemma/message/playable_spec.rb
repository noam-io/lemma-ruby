describe Noam::Message::Playable do
  describe "#new" do
    it "can be built" do
      Noam::Message::Playable.new(
        :host, :event, :value
      ).class.should == Noam::Message::Playable
    end
  end

  describe "#noam_encode" do
    it "encodes the Playable" do
      Noam::Message::Playable.new(
        "host", "event", "value"
      ).noam_encode.should == '000032["event","host","event","value"]'
    end
  end
end
