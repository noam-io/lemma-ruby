require 'noam_lemma'

# This is an example of a Ruby Lemma that publishes message and *also* uses the
# "Guest" model of connection. This Lemma will advertise that it's available on
# the local network and only begin playing messages once a server requests a
# connection from the Lemma.

publisher = Noam::Lemma.new(
  'example-guest-publisher',
  'ruby-script',
  9000,
  [],
  ["e3"])

# Using the `advertise` method asks the Lemma to announce it's presence and
# wait for a message from a server that may want to connect to it.
#
# The "local-test" parameter is the room name. Servers with a room name that's
# the same as the Lemma's advertised room name will connect automatically.
publisher.advertise("")

seq = 0
e = "e3"
loop do
  # Construct a value to send with the event.
  v = {"seq" => seq, "time" => Time.now.to_s}

  # If `play` returns false, we're unable to play the message likely because
  # the socket has closed. The connection would have to be restarted.
  unless publisher.play(e, v)
    puts "Done"
    break
  end
  puts "Wrote: #{e} -> #{v.inspect}"

  seq += 1
  # Sleep for a while so that we don't bog down the network.
  sleep(1)
end
