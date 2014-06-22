class Response

  attr_accessor :message

  def self.from(message)
    Command.process(message)
  end

  def self.greeting(message)
    message.response = Alice::Util::Randomizer.greeting(message.sender_nick)
    message
  end

end
