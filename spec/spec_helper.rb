require 'require_all'

libs = Dir[File.dirname(File.expand_path(__FILE__)) + "/../lib/**/*.rb"]
require_all(libs)

support_libs = Dir[File.dirname(File.expand_path(__FILE__)) + "/support/**/*.rb"]
require_all(support_libs)

class FakeManager
  def self.start
    @@beacon = NoamTest::FakeBeacon.new(Noam::BEACON_PORT)
    @@beacon.start

    @@server = NoamTest::FakeServer.new
    @@server.start
  end

  def self.stop
    @@beacon.stop
    @@server.stop
  end

  def self.server
    @@server
  end
end

RSpec.configure do |config|
  config.mock_framework = :mocha
end
