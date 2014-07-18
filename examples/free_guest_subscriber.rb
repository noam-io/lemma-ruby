require 'noam_lemma'

# This is an example of a Ruby Lemma that publishes message and *also* uses the
# "Guest" model of connection. This Lemma will advertise that it's available on
# the local network, without a specified room, and will only begin subscribing
# to messages once a server requests a connection from the Lemma.

subscriber = Noam::Lemma.new('example-guest-subscriber', ["e3"], [])

# Using the `discover` method asks the Lemma to announce it's presence and
# wait for a message from a server that may want to connect to it.

subscriber.discover

loop do
  # The `listen` method will return an Event object once one is received by the
  # Lemma. Until an event is heard, the `listen` method blocks.
  begin
    m = subscriber.listen
  rescue Noam::Disconnected
    puts "Disconnected"
    break
  end

  # There's one special value that's returned from `listen`: the `:cancelled`
  # symbol. If this shows up, it means some one else has called the `stop`
  # method on the Lemma.
  if :cancelled == m
    puts "Done"
    break
  else
    puts "Read: #{m.event} -> #{m.value.inspect}"
  end
end
