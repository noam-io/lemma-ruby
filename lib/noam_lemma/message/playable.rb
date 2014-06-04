module Noam
  module Message
    class Playable
      def initialize(host_id, event, value)
        @host_id = host_id
        @event = event
        @value = value
      end

      def noam_encode
        j = ['event', @host_id, @event, @value].to_json
        Noam::Message.encode_length(j.length) + j
      end
    end
  end
end
