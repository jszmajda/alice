require "open-uri"
require "nokogiri"

module Pipeline

  class Processor

    include PoroPlus

    attr_accessor :message, :response_method, :trigger

    def self.process(message, response_method)
      new(
        message: message,
        response_method: response_method,
        trigger: message.trigger
      ).react
    end

    def self.sleep
      last_commit_message = Parser::GitHub.fetch.commits.first
      Pipeline::Mediator.emote("reboots with master at '#{last_commit_message}'.")
    end

    def react
      track_sender
      should_respond? ? public_send(self.response_method) : message
    end

    def should_respond?
      return true if self.trigger[0] == "!"
      return true if self.trigger =~ /\+\+/ && self.trigger !~ /$\s*c\+\+/i
      return true if self.trigger =~ /^[0-9\.\-]+$/
      return true if self.trigger =~ /well[,]* actually/i
      return true if self.trigger =~ /so say we all/i
      return true if self.trigger =~ /#{ENV['BOT_SHORT_NAME']}/i
      return true if self.response_method == :greet_on_join
      return true if self.response_method == :track_nick_change
      return true if self.response_method == :heartbeat
      false
    end

    def respond
      if response = Pipeline::Commander.process(self.message).response
        if self.message.response_type == "emote"
          Pipeline::Mediator.emote(response)
        else
          Pipeline::Mediator.reply_with(response)
        end
      end
      message
    end

    private

    def track_sender
      return unless self.message.sender_nick
      self.message.sender && self.message.sender.active!
    end

  end
end
