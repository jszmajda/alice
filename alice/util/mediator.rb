module Alice

  module Util

    class Mediator

      def self.bot_name
        Alice.bot.bot.nick
      end

      def self.non_op?(channel_user)
        ! op?(channel_user)
      end

      def self.op?(channel_user)
        channel_user.channel.ops.map(&:nick).include?(channel_user.user.nick)
      end

      def self.exists?(nick)
        Alice.bot.bot.user_list.find(nick)
      end

      def self.user_list
        Alice.bot.bot.user_list
      end

      def self.is_bot?(nick)
        Alice.bot.bot.nick == nick
      end

      def self.reply_to(channel_user, message)
        text = Alice::Util::Sanitizer.process(message)
        text = Alice::Util::Sanitizer.initial_upcase(text)
        channel_user.reply(text)
      end

      def self.emote_to(channel_user, message)
        text = Alice::Util::Sanitizer.process(message)
        text = Alice::Util::Sanitizer.initial_downcase(text)
        channel_user.action_reply(text)
      end

    end

  end

end