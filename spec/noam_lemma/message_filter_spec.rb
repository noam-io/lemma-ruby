describe Noam::MessageFilter do
  let(:filter)  { Noam::MessageFilter.new }
  let(:message) { stub_message("example_event") }

  describe "#hear" do
    it "registers event names with the filter" do
      filter.hear("example_event") {}
      filter.hear("sample_event") {}
      filter.hears.should == ["example_event", "sample_event"]
    end
  end

  describe "#hears" do
    it "includes single entries for event names registered multiple times" do
      filter.hear("example_event") {}
      filter.hear("example_event") {}
      filter.hears.should == ["example_event"]
    end
  end

  describe "#receive" do
    it "calls blocks associated with the given event name" do
      messages_received = 0
      filter.hear("example_event") {|message| messages_received += 1}
      filter.receive(message)
      messages_received.should == 1
    end

    it "calls multiple blocks associated with the given event name" do
      message_one = nil, message_two = nil
      filter.hear("example_event") {|message| message_one = message}
      filter.hear("example_event") {|message| message_two = message}
      filter.receive(message)
      message_one.should be(message)
      message_two.should be(message)
    end

    it "ignores blocks associated with other event names" do
      example_received = nil, sample_received = nil
      filter.hear("example_event") {|message| example_received = true}
      filter.hear("sample_event") {|message| sample_received = true}
      filter.receive(stub_message("example_event"))
      example_received.should be_true
      sample_received.should be_false
    end

    it "returns the given message" do
      message = stub_message("example_event")
      result = filter.receive(message)
      result.should be(message)
    end

    it "ignores event names with no associations" do
      message = stub_message("example_event")
      lambda { filter.receive(message) }.should_not raise_error
    end

    it "ignores event names with empty blocks" do
      message = stub_message("example_event")
      filter.hear("example_event") {}
      lambda { filter.receive(message) }.should_not raise_error
    end
  end

  def stub_message(event_name, value = "")
    stub("message", event: event_name, value: value)
  end
end
