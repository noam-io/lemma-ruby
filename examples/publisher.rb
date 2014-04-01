require 'noam_lemma'

# This is an example of a Ruby Lemma that publishes messages. It expects a Noam
# server to be running. It also expects that the nome-lemma.rb file is in the
# search path. If you run this example from the project root, the following
# command should work:
#
#   ruby -Ilib example/publisher.rb
#
# This example _will not_ work on the same machine running the Nome server as
# both programs need to bind to UDP port 1030.

publisher = Noam::Lemma.new(
  'example-publisher',
  'ruby-script',
  9000,
  [],
  ["e1","e2"])

# Using the `discover` method asks the Lemma to proactively try and discover a
# server to connect to on the local network. Once the server is discovered, it
# will connect and send a Nome 'register' message. When `discover` returns, the
# Lemma is ready to send events.
publisher.discover

seq = 0
loop do
  # This method block picks an event to send. It's randomized a bit so that we
  # can see things change over time.
  e = if 0.5 < rand()
        "e1"
      else
        "e2"
      end

  # Next, package the event sequence and the current time into a value.
  v = {"seq" => seq, "time" => Time.now.to_s}

  # Attempt to play the chosen event with the value. Note, the event is either
  # "e1" or "e2" based on how rand() returned.
  unless publisher.play(e, v)
    # If `play` returns false, we're unable to play the message likely because
    # the socket has closed. The connection would have to be restarted.
    puts "Done"
    break
  end
  puts "Wrote: #{e} -> #{v.inspect}"

  seq += 1
  # Sleep for a while so that we don't bog down the network.
  sleep(1)
end
