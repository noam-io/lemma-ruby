module Noam
  module Message
    def self.encode_length(l)
      ("%06u" % l)
    end
  end
end

require 'noam_lemma/message/heard'
require 'noam_lemma/message/marco'
require 'noam_lemma/message/playable'
require 'noam_lemma/message/polo'
require 'noam_lemma/message/register'
