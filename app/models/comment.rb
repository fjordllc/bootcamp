# frozen_string_literal: true

class Comment < ActiveRecord::Base
  include Reactionable

  belongs_to :user, touch: true
  belongs_to :commentable, polymorphic: true
  after_save CommentCallbacks.new
  after_create CommentCallbacks.new
  alias_method :sender, :user

  validates :description, presence: true

  def receiver
    commentable.user
  end

  def mentions
    extract_mentions(description)
  end

  def mentions?
    mentions.present?
  end

  def mentions_were
    extract_mentions(description_before_last_save || "")
  end

  def new_mentions
    mentions - mentions_were
  end

  def new_mentions?
    new_mentions.present?
  end

  def self.group_by_user
    where(
      id: self
        .select("DISTINCT ON (user_id) id")
        .order(:user_id, created_at: :desc)
      )
    .order(created_at: :desc)
  end

  def self.recent_unique_users
    group_by_user.map(&:user).reverse
  end

  private
    def extract_mentions(text)
      text.scan(/@\w+/).uniq.map { |s| s.gsub(/@/, "") }
    end
end
