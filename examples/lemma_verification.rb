require "noam_lemma"

class Noam::LemmaVerification
  def self.run
    VerifyUsingReturns.new.run
    VerifyUsingBlocks.new.run
  end

  class VerifyTemplate
    attr_reader :lemma

    def run
      lemma.advertise("lemma_verification")
      verify
      lemma.stop
    end

    private

    def echo(event)
      lemma.speak("EchoVerify", event.value)
    end

    def plus_one(event)
      lemma.speak("PlusOneVerify", event.value + 1)
    end

    def sum(event)
      lemma.speak("SumVerify", event.value.inject {|sum, v| sum + v})
    end

    def name(event)
      fullname = "#{event.value["firstName"]} #{event.value["lastName"]}"
      lemma.speak("NameVerify", {fullName: fullname})
    end

    def events
      ["Echo", "PlusOne", "Sum", "Name"]
    end

    def speaks
      ["EchoVerify", "PlusOneVerify", "SumVerify", "NameVerify"]
    end
  end

  class VerifyUsingReturns < VerifyTemplate
    def initialize
      @lemma ||= Noam::Lemma.new("verification", events, speaks)
    end

    private

    def verify
      events.length.times { handle_event(lemma.listen) }
    end

    def handle_event(event)
      case event.event
      when "Echo"
        echo(event)
      when "PlusOne"
        plus_one(event)
      when "Sum"
        sum(event)
      when "Name"
        name(event)
      end
    end
  end

  class VerifyUsingBlocks < VerifyTemplate
    def initialize
      @lemma = Noam::Lemma.new("verification")
      prepare_lemma
    end

    private

    def prepare_lemma
      lemma.hear("Echo")    {|event| echo(event)}
      lemma.hear("PlusOne") {|event| plus_one(event)}
      lemma.hear("Sum")     {|event| sum(event)}
      lemma.hear("Name")    {|event| name(event)}
    end

    def verify
      events.length.times { lemma.listen }
    end
  end
end

if __FILE__==$0
  Noam::LemmaVerification.run
end
