require 'noam_lemma'

# This is an example of a Ruby Lemma that subscribes to messages. It expects a
# Nome server to be running. It also expects that the nome-lemma.rb file is in
# the search path. If you run this example from the project root, the following
# command should work:
#
#   ruby -Ilib example/subscriber.rb
#
# This example _will not_ work on the same machine running the Nome server as
# both programs need to bind to UDP port 1030.

subscriber = Noam::Lemma.new(
  'example-subscriber',
  'ruby-script',
  9001,
  ["e1","e2"],
  [])

# Using the `discover` method asks the Lemma to proactively try and discover a
# server to connect to on the local network. Once the server is discovered, it
# will connect and send a Nome 'register' message. When `discover` returns, the
# Lemma is ready to receive events.
subscriber.discover

loop do
  # The `listen` method will return an Event object once one is received by the
  # Lemma. Until an event is heard, the `listen` method blocks.
  m = subscriber.listen

  # There's one special value that's returned from `listen`: the `:cancelled`
  # symbol. If this shows up, it means some one else has called the `stop`
  # method on the Lemma.
  if :cancelled == m
    puts "Done"
    break
  else
    puts "Read: #{m.ident} -> #{m.value.inspect}"
  end
end

