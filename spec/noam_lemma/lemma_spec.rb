describe Noam::Lemma do
  SERVER_DELAY = 0.075

  describe "#new" do
    context "with provided arguments" do
      let(:lemma) { Noam::Lemma.new("Example Lemma", ["example_event"], ["sample_event"]) }

      it "sets #name to the given name" do
        lemma.name.should  == "Example Lemma"
      end

      it "sets #hears to the given hears" do
        lemma.hears.should == ["example_event"]
      end

      it "sets #speaks to the given speaks" do
        lemma.speaks.should == ["sample_event"]
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
    let(:lemma) { Noam::Lemma.new("Example Lemma") }

    it "is all messages hearable to the Lemma" do
      lemma.hear("example_event") {}
      lemma.hear("sample_event") {}
      lemma.hears.should == ["example_event", "sample_event"]
    end

    it "does not contain duplicate messages" do
      lemma.hear("example_event") {}
      lemma.hear("example_event") {}
      lemma.hears.should == ["example_event"]
    end
  end

  context "with server communication" do
    let(:server)  { FakeManager.server }
    let(:lemma) { Noam::Lemma.new("Example Lemma") }

    before(:each) do
      Noam::Message::Marco.any_instance.stubs(:start).returns(
        Noam::Message::Polo.new('0.0.0.0', NoamTest::FakeServer::PORT)
      )
      FakeManager.start
      lemma.advertise('fake_beacon')
      sleep(SERVER_DELAY)
    end

    after(:each) do
      lemma.stop
      FakeManager.stop
    end

    describe "#advertise" do
      it "sends a registration message" do
        server.clients.length.should == 1
        server.clients.first.port.should be_an(Integer)
        server.clients.first.port.should_not == 0
      end

      it "initializes listener and player" do
        lemma.listener.should_not be_nil
        lemma.player.should_not be_nil
      end
    end

    describe "#hear" do
      it "registers messages with blocks" do
        message = nil
        lemma.hear("example_event") { |event| message = event }
        send_message_from_server("example_event")
        lemma.listen
        message.event.should == "example_event"
      end
    end

    describe "#speak" do
      it "sends a message to the server" do
        lemma.speak("an event", "some value")
        sleep(SERVER_DELAY)
        server.messages.map { |m| m[2] }.include?("an event").should be_truthy
      end

      it "raise a disconnected error if the player is not connected" do
        lemma.player.stubs(:connected?).returns(false)
        expect { lemma.speak('event', 'value') }.to raise_error(Noam::Disconnected)
      end
    end

    describe "#listen" do
      let(:lemma) { Noam::Lemma.new("Example Lemma", ["example_event"]) }

      it "returns a message from the server" do
        send_message_from_server("example_event")
        message = lemma.listen
        message.source.should == "test-server"
        message.event.should  == "example_event"
        message.value.should  == "noam event"
      end

      it "raises a disconnected error if the listener is not connected" do
        lemma.listener.stubs(:connected?).returns(false)
        expect { lemma.listen }.to raise_error(Noam::Disconnected)
      end
    end

    def send_message_from_server(source = "test-server", value = "noam event", message)
      server.send_message(["event", source, message, value])
    end
  end
end
