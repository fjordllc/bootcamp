# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :delete_all
    has_many :commented_users,
             through: :comments,
             source: :user
  end

  def title
    case self
    when Product
      "「#{practice[:title]}」の提出物"
    else
      self[:title]
    end
  end

  def body
    case self
    when Announcement, Event, Report
      self[:description]
    else
      self[:body]
    end
  def commentable_notification_title
    {
      Report: "#{user.login_name}さんの日報「#{title}」",
      Product: "#{user.login_name}さんの#{title}",
      Event: "特別イベント「#{title}」",
      Page: "Docs「#{title}」",
      Announcement: "お知らせ「#{title}」",
      RegularEvent: "定期イベント「#{title}」"
    }[:"#{self.class}"]
  end
end
