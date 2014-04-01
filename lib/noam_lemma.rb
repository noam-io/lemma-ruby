NOAM_SYS_VERSION = '0.2'
Thread.abort_on_exception=true

module Noam
  class NoamThreadCancelled < Exception; end
end

require 'noam_lemma/beacon'
require 'noam_lemma/lemma'
require 'noam_lemma/listener'
require 'noam_lemma/message'
require 'noam_lemma/player'
