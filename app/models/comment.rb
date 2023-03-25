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

  mentionable_as :description, hook_name: :after_commit

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
    Rails.application.routes.url_helpers.polymorphic_path(commentable, anchor:)
  end

  def previous
    commentable.comments.order(created_at: :desc).find_by('created_at < ?', created_at)
  end

  def latest?
    !later_exists?
  end

  def certain_period_passed_since_the_last_comment_by_submitter?(certain_period)
    (created_at.since(certain_period).to_date == Date.current) && latest? && (user == commentable.user)
  end

  private

  def later_exists?
    commentable.comments.where('created_at > ?', created_at).exists?
  end
end
