# frozen_string_literal: true

module Mentioner
  def after_save_mention(mentions)
    new_mention_users.each do |receiver|
      NotificationFacade.mentioned(self, receiver) if receiver && sender != receiver
    end

    return unless mentions.include? "@mentor"

    User.mentor.each do |receiver|
      NotificationFacade.mentioned(self, receiver) if sender != receiver
    end
  end

  def new_mention_users
    names = new_mentions.map { |s| s.gsub(/@/, "") }
    User.where(login_name: names)
  end

  def where_mention
    case self
    when Product
      "#{user.login_name}さんの「#{practice[:title]}」の提出物"
    when Report
      "#{user.login_name}さんの日報「#{self[:title]}」"
    when Comment
      target_of_comment(commentable.class, commentable) + "へのコメント"
    end
  end

  def body
    self[:body] || self[:description]
  end

  private

  def target_of_comment(commentable_class, commentable)
    {
      Report: "#{commentable.user.login_name}さんの日報「#{commentable.title}」",
      Product: "#{commentable.user.login_name}さんの#{commentable.title}",
      Event: "イベント「#{commentable.title}」",
      Page: "Docs「#{commentable.title}」",
      Announcement: "お知らせ「#{commentable.title}」"
    }[:"#{commentable_class}"]
  end
end
