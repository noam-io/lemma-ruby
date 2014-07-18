Thread.abort_on_exception = true

module Noam
  BEACON_PORT = 1030

  VERSION = '0.2.1'
  DEVICE_TYPE = 'ruby-script'

  class NoamThreadCancelled < Exception; end
  class Disconnected < StandardError; end
end

require 'noam_lemma/lemma'
require 'noam_lemma/listener'
require 'noam_lemma/message'
require 'noam_lemma/player'
