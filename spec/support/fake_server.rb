require 'json'
require 'socket'

class FakeBeaconThreadCancelled < Exception; end
class FakeServerThreadCancelled < Exception; end

module NoamTest
  class FakeBeacon
    def initialize(udp_broadcast_port)
      @socket = UDPSocket.new
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    end

    def start
      @thread = Thread.new do |t|
        begin
          loop do
            msg = ["beacon", "fake_beacon", 8081].to_json
            @socket.send(msg, 0, "255.255.255.255", FAKE_BEACON_PORT)
            sleep(5.0)
          end
        rescue FakeBeaconThreadCancelled
          # going down
        end
      end
    end

    def stop
      @thread.raise(FakeBeaconThreadCancelled)
      @thread.join
      @thread = nil
    end
  end

  class FakeServer
    attr_reader :clients

    def initialize(tcp_listen_port)
      @sock = TCPServer.new(FAKE_TCP_SERVER_PORT)
    end

    def start
      @clients = []
      @thread = Thread.new do |t|
        begin
          loop do
            s = @sock.accept
            @clients << (c = Client.new(s))
            c.start
          end
        rescue FakeServerThreadCancelled
          # going down
        end
      end
    end

    def stop
      @thread.raise(FakeServerThreadCancelled)
      @thread.join
      @thread = nil

      @clients.each do |c|
        c.stop
      end
      @clients = nil
    end

    def msgs
      @clients.map {|c| c.msgs}.flatten(1)
    end
  end

  class Client
    def initialize(client_socket)
      @sock = client_socket
      @queue = Queue.new
    end
    
    def start
      @thread = Thread.new do |t|
        begin
          loop do
            len = @sock.read(6)
            @queue.push(JSON.parse(@sock.read(len.to_i)))
          end
        rescue FakeServerThreadCancelled
          # going down
        end
      end
    end

    def stop
      @thread.raise(FakeServerThreadCancelled)
      @thread.join
    end

    def msgs
      @queue.length.times.map { @queue.pop }
    end
  end
end
