describe Noam::Message::Heard do
  describe "#new" do
    it "creates a new Heard message" do
      h = Noam::Message::Heard.new("source", "ident", "value")
      h.source.should == "source"
      h.ident.should == "ident"
      h.value.should == "value"
    end
  end

  describe "::from_noam" do
    it "ceates a new Heard message from the noam event structure" do
      h = Noam::Message::Heard.from_noam(["event", "source", "ident", "value"].to_json)
      h.source.should == "source"
      h.ident.should == "ident"
      h.value.should == "value"
    end
  end
end
