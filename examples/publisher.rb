require 'noam_lemma'

# This is an example of a Ruby Lemma that publishes messages. It expects a Noam
# server to be running. It also expects that the noam-lemma.rb file is in the
# search path. If you run this example from the project root, the following
# command should work:
#
#   ruby -Ilib example/publisher.rb

publisher = Noam::Lemma.new('example-publisher', [], ["e1", "e2"])

# Using the `advertise` method asks the Lemma to announce it's presence and
# wait for a message from a server that may want to connect to it.
#
# The "local-test" parameter is the room name. Servers with a room name that's
# the same as the Lemma's advertised room name will connect automatically.
publisher.advertise("local-test")

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

  # Attempt to speak the chosen event with the value. Note, the event is either
  # "e1" or "e2" based on how rand() returned.
  begin
    publisher.speak(e, v)

    # If `speak` returns a Noam::Disconnected error, we're unable to speak the
    # message likely because the socket has closed. The connection
    # would have to be restarted.
  rescue Noam::Disconnected
    puts "Disconnected"
    break
  end

  puts "Wrote: #{e} -> #{v.inspect}"

  seq += 1
  # Sleep for a while so that we don't bog down the network.
  sleep(1)
end
