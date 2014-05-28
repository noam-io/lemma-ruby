describe Noam::Message::Heard do
  describe "#new" do
    it "creates a new Heard message" do
      h = Noam::Message::Heard.new("source", "event", "value")
      h.source.should == "source"
      h.event.should == "event"
      h.value.should == "value"
    end
  end

  describe "::from_noam" do
    it "ceates a new Heard message from the noam event structure" do
      h = Noam::Message::Heard.from_noam(["event", "source", "event", "value"].to_json)
      h.source.should == "source"
      h.event.should == "event"
      h.value.should == "value"
    end
  end
end
