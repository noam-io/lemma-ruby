require "noam_lemma"

class Noam::LemmaVerification
  def self.run
    echo
    plus_one
    sum
    name
  end

  def self.echo
    lemma = Noam::Lemma.new("verification", ["Echo"], ["EchoVerify"])
    lemma.advertise("lemma_verification")
    event = lemma.listen
    lemma.speak("EchoVerify", event.value)
    lemma.stop
  end

  def self.plus_one
    lemma = Noam::Lemma.new("verification", ["PlusOne"], ["PlusOneVerify"])
    lemma.advertise("lemma_verification")
    event = lemma.listen
    lemma.speak("PlusOneVerify", event.value + 1)
    lemma.stop
  end

  def self.sum
    lemma = Noam::Lemma.new("verification", ["Sum"], ["SumVerify"])
    lemma.advertise("lemma_verification")
    event = lemma.listen
    lemma.speak("SumVerify", event.value.inject {|sum, v| sum + v})
    lemma.stop
  end

  def self.name
    lemma = Noam::Lemma.new("verification", ["Name"], ["NameVerify"])
    lemma.advertise("lemma_verification")
    event = lemma.listen
    fullname = "#{event.value["firstName"]} #{event.value["lastName"]}"
    lemma.speak("NameVerify", {fullName: fullname})
    lemma.stop
  end
end
