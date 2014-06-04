require "noam_lemma"

class Noam::LemmaVerification
  def self.run
    VerifyUsingReturns.run
    VerifyUsingBlocks.run
  end

  class VerifyUsingReturns
    def self.run
      echo
      plus_one
      sum
      name
    end

    def self.echo
      lemma = Noam::Lemma.new("verification", ["Echo"], ["EchoVerify"])
      verify(lemma) do |event|
        lemma.speak("EchoVerify", event.value)
      end
    end

    def self.plus_one
      lemma = Noam::Lemma.new("verification", ["PlusOne"], ["PlusOneVerify"])
      verify(lemma) do |event|
        lemma.speak("PlusOneVerify", event.value + 1)
      end
    end

    def self.sum
      lemma = Noam::Lemma.new("verification", ["Sum"], ["SumVerify"])
      verify(lemma) do |event|
        lemma.speak("SumVerify", event.value.inject {|sum, v| sum + v})
      end
    end

    def self.name
      lemma = Noam::Lemma.new("verification", ["Name"], ["NameVerify"])
      verify(lemma) do |event|
        fullname = "#{event.value["firstName"]} #{event.value["lastName"]}"
        lemma.speak("NameVerify", {fullName: fullname})
      end
    end

    private

    def self.verify(lemma, &block)
      lemma.advertise("lemma_verification")
      yield lemma.listen
      lemma.stop
    end
  end

  class VerifyUsingBlocks
    def self.run
      echo
      plus_one
      sum
      name
    end

    def self.echo
      lemma = Noam::Lemma.new("verification")
      lemma.hear("Echo") do |event|
        lemma.speak("EchoVerify", event.value)
      end
      verify(lemma)
    end

    def self.plus_one
      lemma = Noam::Lemma.new("verification")
      lemma.hear("PlusOne") do |event|
        lemma.speak("PlusOneVerify", event.value + 1)
      end
      verify(lemma)
    end

    def self.sum
      lemma = Noam::Lemma.new("verification")
      lemma.hear("Sum") do |event|
        lemma.speak("SumVerify", event.value.inject {|sum, v| sum + v})
      end
      verify(lemma)
    end

    def self.name
      lemma = Noam::Lemma.new("verification")
      lemma.hear("Name") do |event|
        fullname = "#{event.value["firstName"]} #{event.value["lastName"]}"
        lemma.speak("NameVerify", {fullName: fullname})
      end
      verify(lemma)
    end

    private

    def self.verify(lemma)
      lemma.advertise("lemma_verification")
      lemma.listen
      lemma.stop
    end
  end
end
