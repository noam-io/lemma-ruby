require 'noam-lemma'
require 'socket'

# expects a Noam server to be running

publisher = Noam::Lemma.new(
  'example-publisher',
  'ruby-script',
  9000,
  [],
  ["e1","e2"])

publisher.start

seq = 0
loop do
  e = if 0.5 < rand()
        "e1"
      else
        "e2"
      end
  v = {"seq" => seq, "time" => Time.now.to_s}

  unless publisher.play(e, v)
    puts "Done"
    break
  end
  puts "Wrote: #{e} -> #{v.inspect}"

  seq += 1
  sleep(1 + rand())
end
