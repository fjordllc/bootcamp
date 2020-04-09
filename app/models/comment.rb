# frozen_string_literal: true

class Comment < ActiveRecord::Base
  include Reactionable
  include Searchable

  belongs_to :user, touch: true
  belongs_to :commentable, polymorphic: true
  after_save CommentCallbacks.new
  after_create CommentCallbacks.new
  alias_method :sender, :user

  validates :description, presence: true

  concerning :KeywordSearch do
    class_methods do
      private

        def params_for_keyword_search(searched_values = {})
          { commentable_type_eq: searched_values[:commentable_type], groupings: groupings(split_keyword_by_blank(searched_values[:word])) }
        end

        def groupings(words)
          words.map do |word|
            { description_cont_all: word }
          end
        end
    end
  end

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

  private
    def extract_mentions(text)
      text.scan(/@\w+/).uniq.map { |s| s.gsub(/@/, "") }
    end
end
