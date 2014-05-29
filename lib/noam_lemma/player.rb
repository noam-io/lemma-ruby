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
      put(:soft_exit)
      @thread.join
    end

    def stop!
      put(:hard_exit)
      @thread.join
    end

    private

    def manage_queue_on_thread
      @thread = Thread.new do |t|
        begin
          loop do
            message = @queue.pop
            break if exit?(message)
            process(message)
          end
        ensure
          @socket.close
        end
      end
    end

    def process(message)
      case message
      when :soft_exit
        finish_queue
      when :hard_exit
      else
        @socket.print(message.noam_encode)
        @socket.flush
      end
    end

    def exit?(message)
      message == :hard_exit || message == :soft_exit
    end

    def finish_queue
      queue_to_array.each do |message|
        @socket.print(message.noam_encode)
        @socket.flush
      end
    end

    def queue_to_array
      result = []
      while(@queue.size > 0) do
        result << @queue.pop
      end
      result
    end
  end
end
