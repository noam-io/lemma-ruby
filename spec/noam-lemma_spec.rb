describe Noam do
  describe Noam::Message::Register do
    pending
  end
  
  describe Noam::Message::Heard do
    pending
  end
  
  describe Noam::Message::Playable do
    pending
  end
  
  describe Noam::Beacon do
    pending
  end
  
  describe Noam::Player do
    pending
  end
  
  describe Noam::Listener do
    pending
  end
  
  describe Noam::Lemma do
    before do
      FakeManager.start
      @server = FakeManager.server

      @lemma = Noam::Lemma.new(
        "my-lemma-name", "ruby-script", 9000,
        ["event1"], ["event1"])
      @lemma.start
      sleep(0.1) # give things enough time to pass the message
    end
    
    after do
      @lemma.stop
      FakeManager.stop
    end

    describe "#new" do
      it "initailizes things" do
        @lemma.name.should == "my-lemma-name"
        @lemma.hears.should == ["event1"]
        @lemma.plays.should == ["event1"]
      end
    end

    describe "#start" do
      it "is sends a registration message" do
        @server.clients.length.should == 1
        @server.clients.first.resp_port.should == 9000
      end

      it "initializes listener and player" do
        @lemma.listener.should_not be_nil
        @lemma.player.should_not be_nil
      end
    end

    describe "#play" do
      it "sends an event to the server" do
        @lemma.play("an event", "some value")
        sleep(0.1)
        @server.msgs.map{|m| m[2]}.include?("an event").should be_true
      end
    end

    describe "#listen" do
      it "returns a message from the server" do
        @server.send_message(["event", "test-server", "event1", "noam event"])
        m = @lemma.listen
        m.source.should == "test-server"
        m.ident.should == "event1"
        m.value.should =="noam event"
      end
    end
  
    describe "#listen" do
      it "receives messages from the server" do
        @server.send_message(["event", "test-server", "event1", "noam event"])
        m = @lemma.listen
        m.ident.should == "event1"
        m.value.should == "noam event"
      end
    end

    describe "#stop" do
      # turns out #stop is hard to describe because it interferes with the running of the other tests.
    end
  end
end
