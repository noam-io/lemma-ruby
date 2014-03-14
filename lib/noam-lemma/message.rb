module Noam
  module Message
    def self.encode_length(l)
      ("%06u" % l)
    end
  end
end

require 'noam-lemma/message/heard'
require 'noam-lemma/message/marco'
require 'noam-lemma/message/playable'
require 'noam-lemma/message/polo'
require 'noam-lemma/message/register'
