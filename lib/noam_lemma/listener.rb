require 'thread' 

module Noam
  class Listener
    attr_reader :port

    def initialize
      @queue = Queue.new
      @server = TCPServer.new(0)
      @port = @server.addr[1]

      @thread = Thread.new do |t|
        begin
          loop do
            client = @server.accept
            loop do
              len = client.read(6).to_i
              data = client.read(len)

              @queue.push(Message::Heard.from_noam(data))
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
