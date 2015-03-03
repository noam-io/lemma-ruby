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

    class ClientReadError < Exception; end

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
      # how long to wait for the client to say something before we should stop
      # and see if we're exiting
      timeout_sec = 0.1

      # how long we should wait for new data on the socket before giving up on
      # the client
      read_timeout_sec = 0.1

      begin
        loop do
          if IO.select([client], nil, nil, timeout_sec)
            message_length = read_exactly(client, Message::MESSAGE_LENGTH_STRING_SIZE, read_timeout_sec).to_i
            message_content = read_exactly(client, message_length, read_timeout_sec)
            @queue.push(Message::Heard.from_noam(message_content))
          end
          break if exiting?
        end
      rescue IO::WaitReadable
        retry unless exiting?
      rescue ClientReadError
        @disconnected = true
      end
    end

    def exiting?
      return @exit_requested
    end

    # Attempts to read exactly `len` bytes from `handle`. If an individual read
    # times out before `len` bytes have been read, `ClientReadError` is raised
    # and data already read is lost.
    #
    # if EOF happens before `len` bytes are read, `ClientReadError` is raised
    # and the data is lost.
    def read_exactly(handle, len, timeout_sec=nil)
      rem_len = len
      msg = ""
      loop do
        if IO.select([handle], nil, nil, timeout_sec)
          # select says something is ready
          m = handle.read(rem_len)

          if m.nil?
            # looks like we found the end of the file
            raise ClientReadError.new("EOF")
          else
            # we got some data. save it and update the remaining length
            rem_len -= m.length
            msg << m
          end

          if 0 >= rem_len
            return msg
          end
        else
          raise ClientReadError.new("Timeout")
        end
      end
    end
  end
end
