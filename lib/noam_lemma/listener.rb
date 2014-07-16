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

        if exiting?
          @queue.push(:cancelled)
          break
        end
      end
    end

    def listen_for_connection
      timeout_sec = 0.1
      available_ios = select([@server], nil, nil, timeout_sec)
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
      end
    end

    def exiting?
      return @exit_requested
    end
  end
end
