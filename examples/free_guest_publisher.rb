require 'noam_lemma'

# This is an example of a Ruby Lemma that publishes message and *also* uses the
# "Guest" model of connection. This Lemma will advertise that it's available on
# the local network, without a specified room, and will only begin speaking
# messages once a server requests a connection from the Lemma.

publisher = Noam::Lemma.new('example-guest-publisher', [], ["e3"])

# Using the `discover` method asks the Lemma to announce it's presence and
# wait for a message from a server that may want to connect to it.

publisher.discover

seq = 0
e = "e3"
loop do
  # Construct a value to send with the event.
  v = {"seq" => seq, "time" => Time.now.to_s}

  # If `speak` raises a Noam::Disconnected error, we're unable to speak the message likely because
  # the socket has closed. The connection would have to be restarted.
  begin
    publisher.speak(e, v)
  rescue Noam::Disconnected
    puts "Disconnectd"
    break
  end

  puts "Wrote: #{e} -> #{v.inspect}"

  seq += 1
  # Sleep for a while so that we don't bog down the network.
  sleep(1)
end
