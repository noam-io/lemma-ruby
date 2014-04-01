module Noam
  module Message
    class Playable
      def initialize(host_id, ident, value)
        @host_id = host_id
        @ident = ident
        @value = value
      end

      def nome_encode
        j = ['event', @host_id, @ident, @value].to_json
        Noam::Message.encode_length(j.length) + j
      end
    end
  end
end
