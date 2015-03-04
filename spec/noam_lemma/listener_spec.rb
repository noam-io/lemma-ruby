describe Noam::Listener do
  def make_message(message)
    ['test', 'source', 'event', message].to_json
  end

  class MockTcpSocket
    MESSAGE = '["event","test-server","example_event","hello noam"]'

    def read(size)
      if size == ::Noam::Message::MESSAGE_LENGTH_STRING_SIZE
        sprintf("%06d", MESSAGE.length)
      else
        MESSAGE
      end
    end

    def close; end
  end

  let!(:listener) { described_class.new }
  let(:mock_socket) { MockTcpSocket.new }

  before do
    TCPServer.any_instance.stubs(:accept).returns(mock_socket)
    IO.stubs(:select).returns(true)
  end

  after do
    listener.stop
  end

  describe '#connected?' do
    it 'returns true if the connection is open' do
      expect(listener.connected?).to be_truthy
    end

    it 'returns false if a read has failed' do
      mock_socket.stubs(:read).raises(Noam::Listener::ClientReadError.new("test error"))
      sleep(0.1) # give things enough time to move through the queues
      expect(listener.connected?).to be_falsey
    end
  end

  describe '#take' do
    it 'returns the next message from the queue' do
      expect(listener.take.value).to eq('hello noam')
    end
  end
end
