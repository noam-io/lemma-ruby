Thread.abort_on_exception = true

module Noam
  BEACON_PORT = 1030
  SERVER_PORT = 7733

  VERSION = '0.2.1'
  DEVICE_TYPE = 'ruby-script'

  class NoamThreadCancelled < Exception; end
end

require 'noam_lemma/beacon'
require 'noam_lemma/lemma'
require 'noam_lemma/listener'
require 'noam_lemma/message'
require 'noam_lemma/player'
