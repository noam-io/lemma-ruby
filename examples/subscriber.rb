require 'noam_lemma'

# This is an example of a Ruby Lemma that subscribes to messages. It expects a
# Noam server to be running. It also expects that the noam-lemma.rb file is in
# the search path. If you run this example from the project root, the following
# command should work:
#
#   ruby -Ilib example/subscriber.rb
#
# This example _will not_ work on the same machine running the Noam server as
# both programs need to bind to UDP port 1030.

subscriber = Noam::Lemma.new('example-subscriber', ["e1", "e2"], [])

# The `hear` method sets a a block of code to be called when an event is heard
# from a specific event.
subscriber.hear('e1') do |message|
  puts "Heard message"
  puts "Event: #{message.event}"
  puts "Value: #{message.value.inspect}"
end

# Using the `advertise` method asks the Lemma to proactively try and discover a
# server to connect to on the local network. Once the server is discovered, it
# will connect and send a Noam 'register' message. When `discover` returns, the
# Lemma is ready to receive events.
subscriber.advertise("local-test")

loop do
  # The `listen` method will return a Message::Heard object once one is received by the
  # Lemma, after calling any blocks associated with the event through the `hear`
  # method. Until an event is heard, the `listen` method blocks.
  begin
    m = subscriber.listen
    puts "Read: #{m.event} -> #{m.value.inspect}"
  rescue Noam::Disconnected
    puts "Disconnected"
    break
  end
end
