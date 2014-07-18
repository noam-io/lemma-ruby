describe Noam::Player do
  def make_message(message)
    Noam::Message::Playable.new('host', 'event', message)
  end

  class MockTcpSocket
    def published_messages
      @published_messages ||= []
    end

    def print(message)
      published_messages << message
    end

    def close; end

    def flush; end
  end

  let(:player) { described_class.new('0.0.0.0', 1234) }
  let(:mock_socket) { MockTcpSocket.new }

  before do
    TCPSocket.stubs(:new).returns(mock_socket)
  end

  describe "connected?" do
    it "returns true if the socket is open" do
      player.stop
      expect(player.connected?).to be_truthy
    end

    it "returns false if a write to the socket has failed" do
      mock_socket.stubs(:print).raises(Errno::EPIPE.new)
      player.put(make_message("message"))
      player.stop
      expect(player.connected?).to be_falsey
    end
  end

  describe "stop" do
    it "publishes the remaning messages in the queue" do
      100.times do
        player.put(make_message("message"))
      end
      player.stop
      expect(mock_socket.published_messages.size).to eq(100)
    end
  end

  describe "stop!" do
    it "does not finish the queue" do
      100.times do
        player.put(make_message("message"))
      end
      player.stop!
      expect(mock_socket.published_messages.size).to be < 100
    end
  end
end
