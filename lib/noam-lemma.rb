NOAM_SYS_VERSION = '0.2'
Thread.abort_on_exception=true

module Noam
  class NoamThreadCancelled < Exception; end
end

require 'noam-lemma/beacon'
require 'noam-lemma/lemma'
require 'noam-lemma/listener'
require 'noam-lemma/message'
require 'noam-lemma/player'
