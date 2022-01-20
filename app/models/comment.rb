# frozen_string_literal: true

class Comment < ApplicationRecord
  include Reactionable
  include Searchable
  include Mentioner

  belongs_to :user, touch: true
  belongs_to :commentable, polymorphic: true
  after_create CommentCallbacks.new
  after_update CommentCallbacks.new
  after_destroy CommentCallbacks.new
  alias sender user

  validates :description, presence: true

  columns_for_keyword_search :description

  mentionable_as :description

  class << self
    def commented_users
      User.with_attached_avatar
          .joins(:comments)
          .where(comments: { id: self.select('DISTINCT ON (user_id) id').order(:user_id, created_at: :desc) })
          .order('comments.created_at')
    end

    private

    def params_for_keyword_search(searched_values = {})
      groupings = super
      { commentable_type_in: searched_values[:commentable_type] }.merge(groupings)
    end
  end

  def receiver
    commentable.user
  end

  def path
    Rails.application.routes.url_helpers.polymorphic_path(commentable, anchor: anchor)
  end

  def previous
    commentable.comments.order(created_at: :desc).find_by('created_at < ?', created_at)
  end

  def latest?
    !later_exists?
  end

  private

  def later_exists?
    commentable.comments.where('created_at > ?', created_at).exists?
  end
end
