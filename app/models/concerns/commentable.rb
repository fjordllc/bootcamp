# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :delete_all
    has_many :commented_users,
             through: :comments,
             source: :user
  end

  # コメントしたユーザーを、各ユーザーの最新コメントが古い順に返す（Comment.commented_usersと同じ並び）。
  # commentsが読み込み済みなら、一覧でレコードごとにSQLを発行しないよう、読み込み済みのコメントから求める。
  def users_ordered_by_latest_comment
    return comments.commented_users unless comments.loaded?

    comments.group_by(&:user_id).values
            .map { |user_comments| user_comments.max_by(&:created_at) }
            .sort_by(&:created_at)
            .map(&:user)
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
  end

  def url
    case self
    when Product
      Rails.application.routes.url_helpers.product_path(self)
    when Announcement
      Rails.application.routes.url_helpers.announcement_path(self)
    when Event
      Rails.application.routes.url_helpers.event_path(self)
    when Report
      Rails.application.routes.url_helpers.report_path(self)
    when Talk
      Rails.application.routes.url_helpers.talk_path(self)
    when RegularEvent
      Rails.application.routes.url_helpers.regular_event_path(self)
    when Movie
      Rails.application.routes.url_helpers.movie_path(self)
    else
      raise NotImplementedError, "#{self.class} does not have a defined URL path"
    end
  end
end
