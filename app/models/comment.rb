# frozen_string_literal: true

class Comment < ApplicationRecord
  include Reactionable
  include Searchable
  include Mentioner

  belongs_to :user, touch: true
  belongs_to :commentable, polymorphic: true
  after_create_commit Comment::AfterCreateCallback.new
  after_update Comment::AfterUpdateCallback.new
  after_destroy Comment::AfterDestroyCallback.new
  alias sender user

  validates :description, presence: true

  columns_for_keyword_search :description

  mentionable_as :description, hook_name: :after_commit

  scope :without_private_comment, -> { where.not(commentable_type: %w[Talk Inquiry CorporateTrainingInquiry]) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id description commentable_type commentable_id created_at updated_at user_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user commentable reactions]
  end

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
    commentable.respond_to?(:user) ? commentable.user : nil
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
    (created_at.since(certain_period).to_date == Date.current) && latest? && (user == receiver)
  end

  def title
    commentable.title if commentable.respond_to?(:title)
  end

  def search_title
    title || commentable&.title || 'Comment'
  end

  def search_url
    Rails.application.routes.url_helpers.polymorphic_path(commentable, anchor: "comment_#{id}")
  end

  # 検索での可視性チェック: Talk関連コメントは管理者または相談者のみ表示
  def visible_to_user?(user)
    if commentable.is_a?(Talk)
      user&.admin? || commentable.user_id == user&.id
    else
      true
    end
  end

  private

  def later_exists?
    commentable.comments.where('created_at > ?', created_at).exists?
  end
end
