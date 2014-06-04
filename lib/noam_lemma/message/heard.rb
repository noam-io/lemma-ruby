module Noam
  module Message
    class Heard
      attr_reader :source, :event, :value

      def initialize(source, event, value)
        @source = source
        @event = event
        @value = value
      end

      def self.from_noam(noam)
        _, source, event, value = JSON.parse(noam)
        Heard.new(source, event, value)
      end
    end
  end
end
