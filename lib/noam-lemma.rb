require 'socket'
require 'json'
require 'thread'

NOAM_SYS_VERSION = '0.2'
Thread.abort_on_exception=true

module Noam
  class NoamThreadCancelled < Exception; end

  module Message

    def self.encode_length(l)
      ("%06u" % l)
    end

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
            # if IO.select([reply_socket],[],[], wait_time)
            if IO.select([bcast_socket],[],[], wait_time)
              # Got a reply on the socket.
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

    class Polo
      attr_reader :host, :port

      class InvalidHost < Exception; end
      class InvalidPort < Exception; end

      def initialize(host, port)
        raise InvalidHost.new if (@host = host).nil?
        raise InvalidPort.new if (@port = port).nil?
      end
    end

    class Register
      def initialize(device_id, resp_port, hears, plays, dev_type)
        @device_id = device_id
        @resp_port = resp_port
        @hears = hears
        @plays = plays
        @dev_type = dev_type
      end

      def nome_encode
        j = ["register", @device_id, @resp_port.to_i, @hears, @plays, @dev_type, NOAM_SYS_VERSION].to_json
        Noam::Message.encode_length(j.length) + j
      end
    end

    class Heard
      attr_reader :source, :ident, :value
      def initialize(source, ident, value)
        @source = source
        @ident = ident
        @value = value
      end

      def self.from_nome(nome)
        _, source, ident, value = JSON.parse(nome)
        Heard.new(source, ident, value)
      end
    end

    class Playable
      def initialize(host_id, ident, value)
        @host_id = host_id
        @ident = ident
        @value = value
      end

      def nome_encode
        j = ['event', @host_id, @ident, @value].to_json
        ("%06u" % j.length) + j
      end
    end
  end

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

  class Player
    def initialize(con_host,con_port)
      @socket = TCPSocket.new(con_host, con_port)
      @queue = Queue.new
      @thread = Thread.new do |t|
        begin
          loop do
            @socket.print(@queue.pop.nome_encode)
            @socket.flush
          end
        rescue NoamThreadCancelled
          # going down
        ensure
          @socket.close
        end
      end
    end

    def put(o)
      @queue.push(o)
    end

    def stop
      @thread.raise(NoamThreadCancelled)
      @thread.join
    end
  end

  class Listener
    def initialize(port)
      @queue = Queue.new
      @server = TCPServer.new(port)
      @thread = Thread.new do |t|
        begin
          loop do
            client = @server.accept
            loop do
              len = client.read(6).to_i
              data = client.read(len)

              @queue.push(Message::Heard.from_nome(data))
            end
          end
        rescue NoamThreadCancelled
          @cancelled = true
          @queue.push(:cancelled)
        ensure
          @server.close
        end
      end
    end

    def take
      @queue.pop
    end

    def stop
      @thread.raise(NoamThreadCancelled)
      @thread.join
    end
  end

  class Lemma
    attr_reader :listener, :player, :name, :hears, :plays

    # Initialize a new Lemma instance.
    #
    def initialize(name, dev_type, response_port, hears, plays)
      @name = name
      @dev_type = dev_type
      @response_port = response_port
      @hears = hears
      @plays = plays

      @player = nil
      @listener = nil
    end

    def start(beacon=nil)
      beacon ||= Beacon.discover
      begin_operation(beacon.host, beacon.noam_port)
    end

    def advertise(room_name)
      m = Noam::Message::Marco.new(room_name, @name, @response_port, "ruby-script")
      polo = m.start

      begin_operation(polo.host, polo.port)
    end

    def play(event, value)
      if @player
        @player.put(Noam::Message::Playable.new(@name, event, value))
        true
      else
        false
      end
    end

    def listen
      @listener.take
    end

    def stop
      @player.stop if @player
      @listener.stop if @listener
      @player = nil
      @listener = nil
    end

    private

    def begin_operation(host, port)
      @listener = Listener.new(@response_port)
      @player = Player.new(host, port)
      @player.put(Message::Register.new(
        @name, @response_port, @hears, @plays, @dev_type))
    end
  end
end
