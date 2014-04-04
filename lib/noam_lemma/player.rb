require 'thread' 

module Noam
  class NoamPlayerException < Exception; end
  class Player
    def initialize(con_host,con_port)
      begin
        @socket = TCPSocket.new(con_host, con_port)
      rescue Errno::ECONNREFUSED
        raise NoamPlayerException.new("Unable to connect to the Noam server at #{con_host}:#{con_port}. Is it running?")
      end

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
