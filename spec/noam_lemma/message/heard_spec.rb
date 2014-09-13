describe Noam::Message::Heard do
  describe "#new" do
    it "creates a new Heard message" do
      h = Noam::Message::Heard.new("source", "event", "value")
      expect(h.source).to eq("source")
      expect(h.event).to eq("event")
      expect(h.value).to eq("value")
    end
  end

  describe "::from_noam" do
    it "ceates a new Heard message from the noam event structure" do
      h = Noam::Message::Heard.from_noam(["event", "source", "event", "value"].to_json)
      expect(h.source).to eq("source")
      expect(h.event).to eq("event")
      expect(h.value).to eq("value")
    end
  end
end
