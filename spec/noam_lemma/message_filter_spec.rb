describe Noam::MessageFilter do
  let(:filter)  { Noam::MessageFilter.new }
  let(:message) { stub_message("example_event") }

  describe "#hear" do
    it "registers event names with the filter" do
      filter.hear("example_event") {}
      filter.hear("sample_event") {}
      expect(filter.hears).to eq(["example_event", "sample_event"])
    end
  end

  describe "#hears" do
    it "includes single entries for event names registered multiple times" do
      filter.hear("example_event") {}
      filter.hear("example_event") {}
      expect(filter.hears).to eq(["example_event"])
    end
  end

  describe "#receive" do
    it "calls blocks associated with the given event name" do
      messages_received = 0
      filter.hear("example_event") {|message| messages_received += 1}
      filter.receive(message)
      expect(messages_received).to eq(1)
    end

    it "calls multiple blocks associated with the given event name" do
      message_one = nil, message_two = nil
      filter.hear("example_event") {|message| message_one = message}
      filter.hear("example_event") {|message| message_two = message}
      filter.receive(message)
      expect(message_one).to eq(message)
      expect(message_two).to eq(message)
    end

    it "ignores blocks associated with other event names" do
      example_received = nil, sample_received = nil
      filter.hear("example_event") {|message| example_received = true}
      filter.hear("sample_event") {|message| sample_received = true}
      filter.receive(stub_message("example_event"))
      expect(example_received).to be_truthy
      expect(sample_received).to be_falsy
    end

    it "returns the given message" do
      message = stub_message("example_event")
      result = filter.receive(message)
      expect(result).to eq(message)
    end

    it "ignores event names with no associations" do
      message = stub_message("example_event")
      expect(
        lambda { filter.receive(message) }
      ).to_not raise_error
    end

    it "ignores event names with empty blocks" do
      message = stub_message("example_event")
      filter.hear("example_event") {}
      expect(
        lambda { filter.receive(message) }
      ).to_not raise_error
    end
  end

  def stub_message(event_name, value = "")
    stub("message", event: event_name, value: value)
  end
end
