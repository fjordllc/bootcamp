# frozen_string_literal: true

class Comment < ApplicationRecord
  include Reactionable
  include Searchable
  include Mentioner

  belongs_to :user, touch: true
  belongs_to :commentable, polymorphic: true
  after_create Comment::AfterCreateCallback.new
  after_update Comment::AfterUpdateCallback.new
  after_destroy Comment::AfterDestroyCallback.new
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
end
