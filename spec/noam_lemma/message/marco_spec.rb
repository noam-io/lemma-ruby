describe Noam::Message::Marco do
  let(:marco)    { described_class.new('test_room', 'Test Lemma') }
  let(:message)  { ['message', 'room', 1234].to_json }
  let(:sockaddr) { [1, 2, 3, 4] }

  before do
    described_class.any_instance.stubs(:message_received?).returns(true)
    UDPSocket.any_instance.stubs(:send)
    UDPSocket.any_instance.stubs(:recvfrom).returns([message, sockaddr])
  end

  it "sends a marco message to the server" do
    UDPSocket.any_instance.expects(:send).with(
      ["marco", 'Test Lemma', 'test_room', Noam::DEVICE_TYPE, Noam::VERSION].to_json,
      0,
      '255.255.255.255',
      Noam::BEACON_PORT
    )
    marco.start
  end

  it "returns a polo with the server's host" do
    polo = marco.start
    expect(polo.host).to eq(3)
  end

  it "returns a polo with the server's port" do
    polo = marco.start
    expect(polo.port).to eq(1234)
  end
end
