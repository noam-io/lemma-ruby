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
      manage_queue_on_thread
    end

    def put(message)
      @queue.push(message)
    end

    def stop
      put(:exit)
      @thread.join
    end

    def stop!
      @thread.exit
    end

    def connected?
      !@disconnected
    end

    private

    def manage_queue_on_thread
      @thread = Thread.new do |t|
        begin
          loop do
            message = @queue.pop
            break if exit?(message)
            print_message(message)
          end
        rescue Errno::EPIPE
          @disconnected = true
        ensure
          @socket.close
        end
      end
    end

    def print_message(message)
      @socket.print(message.noam_encode)
      @socket.flush
    end

    def exit?(message)
      message == :exit
    end
  end
end
