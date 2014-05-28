describe Noam::Lemma do
  SERVER_DELAY = 0.001

  before do
    FakeManager.start
    @server = FakeManager.server
    @lemma = Noam::Lemma.new("my-lemma-name", "ruby-script", 9000, ["event1"], ["event1"])
    @lemma.discover
    sleep(SERVER_DELAY)
  end

  after do
    @lemma.stop
    FakeManager.stop
  end

  describe "#new" do
    it "initailizes things" do
      @lemma.name.should  == "my-lemma-name"
      @lemma.hears.should == ["event1"]
      @lemma.speaks.should == ["event1"]
    end
  end

  describe "#discover" do
    it "sends a registration message" do
      @server.clients.length.should == 1
      @server.clients.first.resp_port.should == 9000
    end

    it "initializes listener and player" do
      @lemma.listener.should_not be_nil
      @lemma.player.should_not be_nil
    end
  end

  describe "#speak" do
    it "sends an event to the server" do
      @lemma.speak("an event", "some value")
      sleep(SERVER_DELAY)
      @server.messages.map{|m| m[2]}.include?("an event").should be_true
    end
  end

  describe "#listen" do
    it "returns a message from the server" do
      @server.send_message(["event", "test-server", "event1", "noam event"])
      message = @lemma.listen
      message.source.should == "test-server"
      message.event.should  == "event1"
      message.value.should  == "noam event"
    end
  end
end
