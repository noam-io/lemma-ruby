module Noam
  module Message
    class Polo
      attr_reader :host, :port

      class InvalidHost < Exception; end
      class InvalidPort < Exception; end

      def initialize(host, port)
        raise InvalidHost.new if (@host = host).nil?
        raise InvalidPort.new if (@port = port).nil?
      end
    end
  end
end
