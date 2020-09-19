# frozen_string_literal: true

module Mentioner
  def after_save_mention(mentions)
    new_mention_users.each do |receiver|
      if receiver && sender != receiver
        NotificationFacade.mentioned(self, receiver)
      end
    end

    if mentions.include? "@mentor"
      User.mentor.each do |receiver|
        if sender != receiver
          NotificationFacade.mentioned(self, receiver)
        end
      end
    end
  end

  def new_mention_users
    names = new_mentions.map { |s| s.gsub(/@/, "") }
    User.where(login_name: names)
  end

  def body
    case self
    when Product
      self[:body]
    else
      self[:description]
    end
  end
end
