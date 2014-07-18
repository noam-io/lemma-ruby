require 'thread'

module Noam
  class Listener
    attr_reader :port

    def initialize
      @queue = Queue.new
      @server = TCPServer.new(0)
      @port = @server.addr[1]

      manage_queue_on_thread
    end

    def take
      @queue.pop
    end

    def stop
      @exit_requested = true
      @thread.join
    end

    def connected?
      !@disconnected
    end

    private

    def manage_queue_on_thread
      @thread = Thread.new do |t|
        begin
          loop_listen
        ensure
          @server.close
        end
      end
    end

    def loop_listen
      loop do
        if client = listen_for_connection
          read_from_client(client)
          client.close
        end

        break if exiting?
      end
    end

    def listen_for_connection
      timeout_sec = 0.1
      available_ios = IO.select([@server], nil, nil, timeout_sec)
      @server.accept if available_ios
    end

    def read_from_client(client)
      begin
        loop do
          message_length = client.read_nonblock(Message::MESSAGE_LENGTH_STRING_SIZE).to_i
          message_content = client.read_nonblock(message_length)
          @queue.push(Message::Heard.from_noam(message_content))
          break if exiting?
        end
      rescue IO::WaitReadable
        retry unless exiting?
      rescue EOFError
        @disconnected = true
      end
    end

    def exiting?
      return @exit_requested
    end
  end
end
