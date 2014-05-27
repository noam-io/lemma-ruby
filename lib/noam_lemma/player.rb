require 'thread' 

module Noam
  class NoamPlayerException < Exception; end
  class Player
    def initialize(remote_host, remote_port)
      begin
        @socket = TCPSocket.new(remote_host, remote_port)
      rescue Errno::ECONNREFUSED
        raise NoamPlayerException.new("Unable to connect to the Noam server at #{remote_host}:#{remote_port}. Is it running?")
      end

      @queue = Queue.new
      @thread = Thread.new do |t|
        begin
          loop do
            @socket.print(@queue.pop.noam_encode)
            @socket.flush
          end
        rescue NoamThreadCancelled
          # going down
        ensure
          @socket.close
        end
      end
    end

    def put(message)
      @queue.push(message)
    end

    def stop
      @thread.raise(NoamThreadCancelled)
      @thread.join
    end
  end
end
