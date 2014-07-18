describe Noam::Listener do
  def make_message(message)
    ['test', 'source', 'event', message].to_json
  end

  class MockTcpSocket
    def queue
      @queue ||= Queue.new
    end

    def read_nonblock(size)
      if size == ::Noam::Message::MESSAGE_LENGTH_STRING_SIZE
        1
      else
        queue.pop
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

  describe '#connected?' do
    it 'returns true if the connection is open' do
      mock_socket.queue << make_message('message')
      listener.stop
      expect(listener.connected?).to be_truthy
    end

    it 'returns false if a read has failed' do
      mock_socket.stubs(:read_nonblock).raises(EOFError.new)
      listener.stop
      expect(listener.connected?).to be_falsey
    end
  end

  describe '#take' do
    it 'returns the next message from the queue' do
      mock_socket.queue << make_message('message')
      listener.stop
      expect(listener.take.value).to eq('message')
    end
  end

  describe '#stop' do
    it 'returns the cancelled signal at the end of the queue' do
      mock_socket.queue << make_message('message_1')
      mock_socket.queue << make_message('message_2')
      mock_socket.queue << make_message('message_3')
      listener.stop
      message = listener.take until message == :cancelled
      expect(message).to eq(:cancelled)
    end
  end
end
