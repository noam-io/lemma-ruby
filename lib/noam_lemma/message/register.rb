module Noam
  module Message
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
  end
end
