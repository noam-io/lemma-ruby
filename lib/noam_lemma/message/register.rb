module Noam
  module Message
    class Register
      def initialize(device_id, port, hears, speaks)
        @device_id = device_id
        @port = port
        @hears = hears
        @speaks = speaks
      end

      def noam_encode
        j = ["register", @device_id, @port.to_i, @hears, @speaks, Noam::DEVICE_TYPE, Noam::VERSION].to_json
        Noam::Message.encode_length(j.length) + j
      end
    end
  end
end
