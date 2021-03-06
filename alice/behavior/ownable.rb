module Behavior

  module Ownable

    def owned_time
      event = self.picked_up_at || self.created_at
      hours = (Time.now.minus_with_coercion(event)/3600).round
      elapsed = hours < 1 && "a short while"
      elapsed ||= hours < 24 && "less than a day"
      elapsed ||= hours / 24 == 1 ? "one day" : "#{hours / 24} days"
      elapsed
    end

    def owner
      self.user || (self.actor && self.actor.proper_name) || Actor.new(name: "Edwina Nobody")
    end

    def owner_name
      owner.proper_name
    end

    def change_owner(recipient)
      return unless recipient
      self.user_id = recipient.id
      self.place_id = nil
      self.picked_up_at = DateTime.now
      self.is_hidden = false
      self.save
    end

    def transfer_to(recipient)
      return unless recipient
      original_owner = self.user
      change_owner(recipient)
      if original_owner && original_owner != recipient
        Util::Randomizer.give_message(original_owner.primary_nick, recipient.primary_nick, self.name_with_article)
      else
        if is_hidden
          self.owner.score_points(1)
          update_attribute(:is_hidden, false)
          return "You found the #{self.name} and win a point!"
        else
          "#{self.user.primary_nick} now has the #{self.name}."
        end
      end
    end

  end

end
