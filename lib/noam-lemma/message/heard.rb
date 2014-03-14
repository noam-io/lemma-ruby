module Noam
  module Message
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
  end
end
