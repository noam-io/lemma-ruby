require 'socket'
require 'json'

module Noam
  module Message
    class Marco
      attr_reader :port

      def initialize(room_name, lemma_name)
        @room_name = room_name
        @lemma_name = lemma_name
      end

      def start
        bcast_socket = UDPSocket.new
        reply_socket = UDPSocket.new
        reply_socket.bind("0.0.0.0", 0)

        begin
          bcast_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

          loop do
            bcast_socket.send(noam_encode, 0, "255.255.255.255", Noam::BEACON_PORT)
            if message_received?(bcast_socket)
              break
            end
          end

          get_polo_response(bcast_socket)
        ensure
          reply_socket.close
        end
      end

      def noam_encode
        ["marco", @lemma_name, @room_name, Noam::DEVICE_TYPE, Noam::VERSION].to_json
      end

      private

      MAX_RESPONSE_LENGTH = 1600
      WAIT_TIME = 5.0

      def message_received?(socket)
        IO.select([socket], [], [], WAIT_TIME)
      end

      def get_polo_response(socket)
        message, sockaddr = socket.recvfrom(MAX_RESPONSE_LENGTH)
        _, _, noam_port = JSON.parse(message)
        _, _, addr, _ = sockaddr

        Polo.new(addr, noam_port)
      end
    end
  end
end
