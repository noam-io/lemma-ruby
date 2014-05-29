module Noam
  class Lemma
    attr_reader :name, :listener, :player, :hears, :speaks

    def initialize(name, hears, speaks)
      @name = name
      @hears = hears
      @speaks = speaks

      @player = nil
      @listener = nil
    end

    def discover(beacon = nil)
      beacon ||= Beacon.discover
      start(beacon.host, beacon.noam_port)
    end

    def advertise(room_name)
      marco = Noam::Message::Marco.new(room_name, @name)
      polo = marco.start
      start(polo.host, polo.port)
    end

    def speak(event, value)
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

    def start(host, port)
      @listener = Listener.new
      @player = Player.new(host, port)
      @player.put(Message::Register.new(@name, @listener.port, @hears, @speaks))
    end
  end
end
