# frozen_string_literal: true

class Comment < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :commentable, polymorphic: true
  before_save CommentCallbacks.new
  after_create CommentCallbacks.new
  alias_method :sender, :user

  validates :description, presence: true

  def reciever
    commentable.user
  end

  def mentions
    extract_mentions(description)
  end

  def mentions?
    mentions.present?
  end

  def mentions_were
    extract_mentions(description_was || "")
  end

  def new_mentions
    mentions - mentions_were
  end

  def new_mentions?
    new_mentions.present?
  end

  def self.pager(page, order = "asc")
    (order == "desc") ? order(created_at: :desc).page(page) : order(created_at: :asc).page(page)
  end

  private
    def extract_mentions(text)
      text.scan(/@\w+/).uniq.map { |s| s.gsub(/@/, "") }
    end
end
