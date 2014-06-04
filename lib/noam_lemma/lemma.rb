require "noam_lemma/message_filter"

module Noam
  class Lemma
    attr_reader :name, :listener, :player, :speaks

    def initialize(name, hears = [], speaks = [])
      @name = name
      @speaks = speaks
      @player = nil
      @listener = nil

      initialize_message_filter(hears)
    end

    def discover(beacon = nil)
      beacon ||= Beacon.discover
      start(beacon.host, beacon.port)
    end

    def advertise(room_name)
      marco = Noam::Message::Marco.new(room_name, @name)
      polo = marco.start
      start(polo.host, polo.port)
    end

    def hear(event_name, &block)
      @message_filter.hear(event_name, &block)
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
      @message_filter.receive(@listener.take)
    end

    def stop
      @player.stop if @player
      @listener.stop if @listener
      @player = nil
      @listener = nil
    end

    def hears
      @message_filter.hears
    end

    private

    def start(host, port)
      @listener = Listener.new
      @player = Player.new(host, port)
      @player.put(Message::Register.new(@name, @listener.port, @message_filter.hears, @speaks))
    end

    def initialize_message_filter(hears)
      @message_filter = MessageFilter.new
      hears.each do |event_name|
        @message_filter.hear(event_name) {}
      end
    end
  end
end
