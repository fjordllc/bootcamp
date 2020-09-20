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

  def where_mention
    case self
    when Product
      "#{self.user.login_name}さんの「#{self.practice[:title]}」の提出物"
    when Report
      "#{self.user.login_name}さんの「#{self[:title]}」の日報"
    when Comment
      "#{self.commentable.user.login_name}さんの#{self.commentable.title}のコメント"
    end
  end

  def body
    self[:body] || self[:description]
  end
end
