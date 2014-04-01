require 'socket'
require 'json'

module Noam
  module Message
    class Marco
      def initialize(room_name, lemma_name, polo_udp_port, dialect)
        @room_name = room_name
        @lemma_name = lemma_name
        @udp_listen_port = polo_udp_port
        @dialect = dialect
      end

      def start
        bcast_socket = UDPSocket.new
        reply_socket = UDPSocket.new
        reply_socket.bind("0.0.0.0", @udp_listen_port)
        begin
          dest_port = 1030
          wait_time = 5.0

          bcast_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

          loop do
            bcast_socket.send(nome_encode, 0, "255.255.255.255", dest_port)
            if IO.select([bcast_socket],[],[], wait_time)
              # Got a reply on the socket. Break out of the loop and process
              # the reply.
              break
            end
          end

          message, sockaddr = bcast_socket.recvfrom(1600)
          _, _, nome_port = JSON.parse(message)
          _, _, addr, _ = sockaddr

          Polo.new(addr, nome_port)
        ensure
          reply_socket.close
        end
      end

      def nome_encode
        ["marco", @lemma_name, @room_name, @dialect, NOAM_SYS_VERSION].to_json
      end
    end
  end
end
