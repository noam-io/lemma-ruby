module Noam
  class Beacon
    attr_reader :name, :host, :noam_port, :http_port

    def initialize(name, host, http_port, noam_port)
      @name = name
      @host = host
      @http_port = http_port
      @noam_port = noam_port
    end

    def self.discover(net="0.0.0.0")
      socket = UDPSocket.new
      begin
        beacon_port = 1030

        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
        socket.bind("0.0.0.0", beacon_port)

        wait_time = 10.0
        if IO.select([socket],[],[],wait_time).nil?
          raise "Didn't see beacon after #{wait_time} seconds."
        else
          data, addr = socket.recvfrom(1600)
          parsed_data = JSON.parse(data)
          Beacon.new(parsed_data[1], addr[2], parsed_data[2], 7733)
        end
      ensure
        socket.close
      end
    end
  end
end
