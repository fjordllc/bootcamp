# frozen_string_literal: true

class Question < ApplicationRecord
  include Searchable
  include Reactionable
  include Watchable
  include WithAvatar
  include Taggable
  include Mentioner
  include Bookmarkable

  QuestionsProperty = Struct.new(:title, :empty_message)

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
  validates :published_at, presence: true, if: :will_be_published?

  scope :solved, -> { where(id: CorrectAnswer.select(:question_id)) }
  scope :not_solved, -> { where.not(id: CorrectAnswer.select(:question_id)) }
  scope :wip, -> { where(wip: true) }
  scope :not_wip, -> { where(wip: false) }
  scope :latest_update_order, -> { order(updated_at: :desc, id: :desc) }
  scope :by_practice_id, ->(practice_id) { where(practice_id:) if practice_id.present? }
  scope :by_tag, ->(tag) { tagged_with(tag) if tag }
  scope :by_target, lambda { |target|
    case target
    when 'solved'
      solved
    when 'not_solved'
      not_solved.not_wip
    else
      all
    end
  }

  columns_for_keyword_search :title, :description

  mentionable_as :description

  class << self
    def notify_certain_period_passed_after_last_answer
      return if Question.not_solved_and_certain_period_has_passed.blank?

      Question.not_solved_and_certain_period_has_passed.each do |not_solved_question|
        ActivityDelivery.with(question: not_solved_question, receiver: not_solved_question.user).notify(:no_correct_answer)
      end
    end

    def not_solved_and_certain_period_has_passed
      not_solved.select do |not_solved_question|
        next if not_solved_question.answers.empty?

        not_solved_question.last_answer.certain_period_has_passed?
      end
    end

    def generate_questions_property(target)
      case target
      when 'solved'
        QuestionsProperty.new('解決済みのQ&A', '解決済みのQ&Aはありません。')
      when 'not_solved'
        QuestionsProperty.new('未解決のQ&A', '未解決のQ&Aはありません。')
      else
        QuestionsProperty.new('全てのQ&A', 'Q&Aはありません。')
      end
    end

    def unsolved_badge(current_user:, practice_id: nil)
      return nil if !current_user.admin_or_mentor?

      if practice_id.present?
        Question.not_solved.not_wip.where(practice_id:).size
      else
        Question.not_solved.not_wip.size
      end
    end
  end

  def last_answer
    answers.max_by(&:created_at)
  end

  def generate_notice_message(action_name)
    return '質問をWIPとして保存しました。' if wip?

    case action_name
    when :create
      '質問を作成しました。'
    when :update
      '質問を更新しました。'
    end
  end

  def url
    Rails.application.routes.url_helpers.question_path(self)
  end

  def formatted_summary(word)
    return description unless word.present?

    description.gsub(/(#{Regexp.escape(word)})/i, '<strong class="matched_word">\1</strong>')
  end

  private

  def will_be_published?
    !wip && published_at.nil?
  end

  def set_published_at
    self.published_at = Time.zone.now
  end
end
