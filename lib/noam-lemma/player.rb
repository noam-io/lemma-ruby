require 'thread' 

module Noam
  class Player
    def initialize(con_host,con_port)
      @socket = TCPSocket.new(con_host, con_port)
      @queue = Queue.new
      @thread = Thread.new do |t|
        begin
          loop do
            @socket.print(@queue.pop.nome_encode)
            @socket.flush
          end
        rescue NoamThreadCancelled
          # going down
        ensure
          @socket.close
        end
      end
    end

    def put(o)
      @queue.push(o)
    end

    def stop
      @thread.raise(NoamThreadCancelled)
      @thread.join
    end
  end
end
