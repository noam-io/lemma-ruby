require 'noam-lemma'
require 'socket'

# expects a Noam server to be running
subscriber = Noam::Lemma.new(
  'example-subscriber',
  'ruby-script',
  9001,
  ["e1","e2"],
  [])

subscriber.start

loop do
  m = subscriber.listen

  if :cancelled == m
    puts "Done"
    break
  else
    puts "Read: #{m.ident} -> #{m.value.inspect}"
  end
end

