# frozen_string_literal: true

class Comment < ActiveRecord::Base
  include Reactionable
  include Searchable

  belongs_to :user, touch: true
  belongs_to :commentable, polymorphic: true
  after_create CommentCallbacks.new
  alias_method :sender, :user

  validates :description, presence: true

  columns_for_keyword_search :description

  mentionable_as :description

  def after_save_mention(mentions)
    mentions.map { |s| s.gsub(/@/, "") }.each do |mention|
      receiver = User.find_by(login_name: mention)
      if receiver && sender != receiver
        NotificationFacade.mentioned(self, receiver)
      end
    end
  end

  class << self
    private

      def params_for_keyword_search(searched_values = {})
        groupings = super
        { commentable_type_in: searched_values[:commentable_type] }.merge(groupings)
      end
  end

  def receiver
    commentable.user
  end

  def self.commented_users
    User.with_attached_avatar
      .joins(:comments)
      .where(comments: { id: self.select("DISTINCT ON (user_id) id").order(:user_id, created_at: :desc) })
      .order("comments.created_at")
  end
end
