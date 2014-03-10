describe Noam::Message do
  describe "#new" do
    it "is sends a registration message" do
      l = Noam::Lemma.new(
        "my-lemma-name", "ruby-script", 9000,
        ["event1"], ["event1"])
      l.start
      sleep(1)
      l.stop

      @server.msgs.map{|m| m[0]}.include?("register").should be_true
    end
  end
end
