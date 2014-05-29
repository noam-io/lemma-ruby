describe Noam::Lemma do
  SERVER_DELAY = 0.05

  before(:each) do
    FakeManager.start
    @server = FakeManager.server
    @lemma = Noam::Lemma.new("Example Lemma", ["event1"], ["event1"])
    @lemma.discover
    sleep(SERVER_DELAY)
  end

  after do
    @lemma.stop
    FakeManager.stop
  end

  describe "#new" do
    context "with provided arguments" do
      let(:lemma) { Noam::Lemma.new("Example Lemma", ["event1"], ["event1"]) }

      it "sets #name to the given name" do
        lemma.name.should  == "Example Lemma"
      end

      it "sets #hears to the given hears" do
        lemma.hears.should == ["event1"]
      end

      it "sets #speaks to the given speaks" do
        lemma.speaks.should == ["event1"]
      end
    end

    context "with default arguments" do
      let(:lemma) { Noam::Lemma.new("Example Lemma") }

      it "sets #hears to an empty array" do
        lemma.hears.should == []
      end

      it "sets #speaks to an empty array" do
        lemma.speaks.should == []
      end
    end
  end

  describe "#hears" do
    let(:lemma) { Noam::Lemma.new("Example Lemma", ["example_event"]) }

    it "delegates to the MessageFilter when set" do
      message_filter = Noam::MessageFilter.new
      message_filter.hear("sample_event") {}
      lemma.set_message_filter(message_filter)
      lemma.hears.should == message_filter.hears
    end
  end

  describe "#discover" do
    it "sends a registration message" do
      @server.clients.length.should == 1
      @server.clients.first.port.should be_an(Integer)
      @server.clients.first.port.should_not == 0
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
