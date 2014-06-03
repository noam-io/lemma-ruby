module Noam
  class Beacon
    attr_reader :name, :host, :port

    def initialize(name, host, port)
      @name = name
      @host = host
      @port = port
    end

    def self.discover(net = "0.0.0.0")
      socket = UDPSocket.new
      begin
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
        socket.bind(net, Noam::BEACON_PORT)

        raise "Didn't see beacon after #{WAIT_TIME} seconds." unless message_received?(socket)

        data, addr = socket.recvfrom(MAX_RESPONSE_LENGTH)
        parsed_data = JSON.parse(data)
        Beacon.new(parsed_data[1], addr[2], parsed_data[2])
      ensure
        socket.close
      end
    end

    private

    MAX_RESPONSE_LENGTH = 1600
    WAIT_TIME = 10.0

    def self.message_received?(socket)
      IO.select([socket], [], [], WAIT_TIME) != nil
    end
  end
end
