require 'require_all'

libs = Dir[File.dirname(File.expand_path(__FILE__)) + "/../lib/**/*.rb"]
require_all(libs)

RSpec.configure do |config|
  config.mock_framework = :mocha
  config.before(:all) do
    # nothing yet
  end
end
