module Noam
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

    def discover(beacon=nil)
      beacon ||= Beacon.discover
      start(beacon.host, beacon.noam_port)
    end

    def advertise(room_name)
      m = Noam::Message::Marco.new(room_name, @name, @response_port, "ruby-script")
      polo = m.start

      start(polo.host, polo.port)
    end

    def start(host, port)
      @listener = Listener.new(@response_port)
      @player = Player.new(host, port)
      @player.put(Message::Register.new(
        @name, @response_port, @hears, @plays, @dev_type))
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
  end
end
