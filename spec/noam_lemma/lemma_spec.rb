describe Noam::Lemma do
  SERVER_DELAY = 0.075

  describe "#new" do
    context "with provided arguments" do
      let(:lemma) { Noam::Lemma.new("Example Lemma", ["example_event"], ["sample_event"]) }

      it "sets #name to the given name" do
        expect(lemma.name).to eq("Example Lemma")
      end

      it "sets #hears to the given hears" do
        expect(lemma.hears).to eq(["example_event"])
      end

      it "sets #speaks to the given speaks" do
        expect(lemma.speaks).to eq(["sample_event"])
      end
    end

    context "with default arguments" do
      let(:lemma) { Noam::Lemma.new("Example Lemma") }

      it "sets #hears to an empty array" do
        expect(lemma.hears).to eq([])
      end

      it "sets #speaks to an empty array" do
        expect(lemma.speaks).to eq([])
      end
    end
  end

  describe "#hears" do
    let(:lemma) { Noam::Lemma.new("Example Lemma") }

    it "is all messages hearable to the Lemma" do
      lemma.hear("example_event") {}
      lemma.hear("sample_event") {}
      expect(lemma.hears).to eq(["example_event", "sample_event"])
    end

    it "does not contain duplicate messages" do
      lemma.hear("example_event") {}
      lemma.hear("example_event") {}
      expect(lemma.hears).to eq(["example_event"])
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
        expect(server.clients.length).to eq(1)
        expect(server.clients.first.port).to be_an(Integer)
        expect(server.clients.first.port).to_not eq(0)
      end

      it "initializes listener and player" do
        expect(lemma.listener).to_not be_nil
        expect(lemma.player).to_not be_nil
      end
    end

    describe "#hear" do
      it "registers messages with blocks" do
        message = nil
        lemma.hear("example_event") { |event| message = event }
        send_message_from_server("example_event")
        lemma.listen
        expect(message.event).to eq("example_event")
      end
    end

    describe "#speak" do
      it "sends a message to the server" do
        lemma.speak("an event", "some value")
        sleep(SERVER_DELAY)
        expect(
          server.messages.map { |m| m[2] }.include?("an event")
        ).to be_truthy
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
        expect(message.source).to eq("test-server")
        expect(message.event).to eq("example_event")
        expect(message.value).to eq("noam event")
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
