# frozen_string_literal: true

class Question < ApplicationRecord
  include Searchable
  include Reactionable
  include Watchable
  include WithAvatar
  include Taggable
  include Mentioner
  include Bookmarkable

  belongs_to :practice, optional: true
  belongs_to :user, touch: true
  has_one :correct_answer, dependent: :destroy
  has_many :answers, dependent: :destroy
  alias sender user

  before_validation :set_published_at, if: :will_be_published?

  after_save QuestionCallbacks.new
  after_destroy QuestionCallbacks.new

  validates :title, presence: true, length: { maximum: 256 }
  validates :description, presence: true
  validates :user, presence: true
  validates :published_at, presence: true, if: :will_be_published?

  scope :solved, -> { where(id: CorrectAnswer.select(:question_id)) }
  scope :not_solved, -> { where.not(id: CorrectAnswer.select(:question_id)) }
  scope :wip, -> { where(wip: true) }
  scope :not_wip, -> { where(wip: false) }

  columns_for_keyword_search :title, :description

  mentionable_as :description

  class << self
    def notify_questioner_to_choose_correct_answer
      Question.not_solved_and_certain_period_has_passed.each do |not_solved_question|
        NotificationFacade.not_yet_chosen_correct_answer(not_solved_question, not_solved_question.user)
      end
    end

    def not_solved_and_certain_period_has_passed
      not_solved.select do |not_solved_question|
        next if not_solved_question.answers.empty?

        not_solved_question.last_answer.certain_period_has_passed?
      end
    end
  end

  def last_answer
    answers.max_by(&:created_at)
  end

  private

  def will_be_published?
    !wip && published_at.nil?
  end

  def set_published_at
    self.published_at = Time.zone.now
  end
end
