require 'require_all'

libs = Dir[File.dirname(File.expand_path(__FILE__)) + "/../lib/**/*.rb"]
require_all(libs)

support_libs = Dir[File.dirname(File.expand_path(__FILE__)) + "/support/**/*.rb"]
require_all(support_libs)

FAKE_BEACON_PORT = 1030
FAKE_TCP_SERVER_PORT = 7733

RSpec.configure do |config|
  config.mock_framework = :mocha

  config.before(:all) do
    @beacon = NoamTest::FakeBeacon.new(FAKE_BEACON_PORT)
    @beacon.start


    @server = NoamTest::FakeServer.new(FAKE_TCP_SERVER_PORT)
    @server.start
  end

  config.after(:all) do
    @beacon.stop
    @server.stop
  end
end
