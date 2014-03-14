require 'thread' 

module Noam
  class Listener
    def initialize(port)
      @queue = Queue.new
      @server = TCPServer.new(port)
      @thread = Thread.new do |t|
        begin
          loop do
            client = @server.accept
            loop do
              len = client.read(6).to_i
              data = client.read(len)

              @queue.push(Message::Heard.from_nome(data))
            end
          end
        rescue NoamThreadCancelled
          @cancelled = true
          @queue.push(:cancelled)
        ensure
          @server.close
        end
      end
    end

    def take
      @queue.pop
    end

    def stop
      @thread.raise(NoamThreadCancelled)
      @thread.join
    end
  end
end
