module Noam
  class MessageFilter
    def initialize
      @hears = {}
    end

    def hear(event_name, &block)
      @hears[event_name] ||= []
      @hears[event_name] << block
    end

    def receive(message)
      blocks = @hears[message.event] || []
      blocks.each do |block|
        block.call(message)
      end
      message
    end

    def hears
      @hears.keys.uniq
    end
  end
end
