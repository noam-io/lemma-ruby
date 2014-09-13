describe Noam::Message::Playable do
  describe "#new" do
    it "can be built" do
      playable = Noam::Message::Playable.new(:host, :event, :value)
      expect(playable).to be_a(Noam::Message::Playable)
    end
  end

  describe "#noam_encode" do
    it "encodes the Playable" do
      playable = Noam::Message::Playable.new("host", "event", "value")
      expect(playable.noam_encode).to eq('000032["event","host","event","value"]')
    end
  end
end
