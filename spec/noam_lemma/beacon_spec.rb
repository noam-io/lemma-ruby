describe Noam::Beacon do
  describe "#new" do
    it "creates a new beacon" do
      beacon = Noam::Beacon.new(:name, :host, :http, :noam)
      beacon.name.should == :name
      beacon.host.should == :host
      beacon.http_port.should == :http
      beacon.noam_port.should == :noam
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
      beacon = Noam::Beacon.discover
      beacon.class.should == Noam::Beacon
      beacon.http_port.should == FAKE_HTTP_PORT
      beacon.noam_port.should == Noam::SERVER_PORT
    end
  end
end
