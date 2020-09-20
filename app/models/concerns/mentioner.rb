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
      "#{self.user.login_name}さんの日報「#{self[:title]}」"
    when Comment
      select_message(self.commentable.class, self.commentable) + "へのコメント"
    end
  end

  def body
    self[:body] || self[:description]
  end

  private

    def select_message(commentable_class, commentable)
      {
        Report: "#{commentable.user.login_name}さんの日報「#{self.commentable.title}」",
        Product: "#{commentable.user.login_name}さんの#{self.commentable.title}",
        Event: "イベント「#{commentable.title}」",
        Page: "Docs「#{commentable.title}」",
        Announcement: "お知らせ「#{commentable.title}」"
      }[:"#{commentable_class}"]
    end
end
