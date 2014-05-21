describe Noam do
  describe Noam::Message do
    describe "::encode_length" do
      it "expands the lengh out to 6 digits" do
        Noam::Message.encode_length(6).should == "000006"
        Noam::Message.encode_length(123456).should == "123456"
      end
    end
  end

  describe Noam::Message::Register do
    describe "#new" do
      it "creates a new Register object" do
        Noam::Message::Register.new(
          :devid, :port, :hears, :plays, :type
        ).class.should == Noam::Message::Register
      end
    end

    describe "#nome_encode" do
      it "encodes the Register message" do
        Noam::Message::Register.new(
          "an_id", 1234, ["e1"], ["e2","e3"], "thingy"
        ).nome_encode.should == '000059["register","an_id",1234,["e1"],["e2","e3"],"thingy","0.2"]'
      end
    end
  end

  describe Noam::Message::Heard do
    describe "#new" do
      it "creates a new Heard message" do
        h = Noam::Message::Heard.new("source", "ident", "value")
        h.source.should == "source"
        h.ident.should == "ident"
        h.value.should == "value"
      end
    end

    describe "::from_nome" do
      it "ceates a new Heard message from the nome event structure" do
        h = Noam::Message::Heard.from_nome(["event", "source", "ident", "value"].to_json)
        h.source.should == "source"
        h.ident.should == "ident"
        h.value.should == "value"
      end
    end
  end

  describe Noam::Message::Playable do
    describe "#new" do
      it "can be built" do
        Noam::Message::Playable.new(
          :host,:ident,:value
        ).class.should == Noam::Message::Playable
      end
    end

    describe "#nome_encode" do
      it "encodes the Playable" do
        Noam::Message::Playable.new(
          "host","ident","value"
        ).nome_encode.should == '000032["event","host","ident","value"]'
      end
    end
  end

  describe Noam::Beacon do
    describe "#new" do
      it "creates a new beacon" do
        b = Noam::Beacon.new(:name,:host, :http, :noam)
        b.name.should == :name
        b.host.should == :host
        b.http_port.should == :http
        b.noam_port.should == :noam
      end
    end

    describe "::discover" do
      before do
        FakeManager.start
      end

      after do
        FakeManager.stop
      end

      it "creats a Beacon based on server beacons" do
        # test assumes the TestBeacon beacon is running.
        b = Noam::Beacon.discover
        b.class.should == Noam::Beacon
        b.http_port.should == 8081
        b.noam_port.should == 7733
      end
    end
  end

  describe Noam::Lemma do
    before do
      FakeManager.start
      @server = FakeManager.server

      @lemma = Noam::Lemma.new(
        "my-lemma-name", "ruby-script", 9000,
        ["event1"], ["event1"])
      @lemma.discover
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

    describe "#stop" do
      # turns out #stop is hard to describe because it interferes with the running of the other tests.
    end
  end
end
