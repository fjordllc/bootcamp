# frozen_string_literal: true

class Answer < ActiveRecord::Base
  include Reactionable
  include Searchable

  belongs_to :user, touch: true
  belongs_to :question
  alias_method :sender, :user

  after_create AnswerCallbacks.new

  validates :description, presence: true
  validates :user, presence: true

  concerning :KeywordSearch do
    class_methods do
      private

        def params_for_keyword_search(searched_values = {})
          { groupings: groupings(split_keyword_by_blank(searched_values[:word])) }
        end

        def groupings(words)
          words.map do |word|
            { description_cont_all: word }
          end
        end
    end
  end

  def receiver
    self.question.user
  end
end
