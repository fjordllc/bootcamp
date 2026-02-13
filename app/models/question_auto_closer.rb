# frozen_string_literal: true

class QuestionAutoCloser
  SYSTEM_USER_LOGIN_NAME = 'pjord'
  WARNING_MESSAGE = 'このQ&Aは1ヶ月間更新がありませんでした。このまま更新がなければ1週間後に自動的にクローズされます。'
  AUTO_CLOSE_MESSAGE = '自動的にクローズしました。'

  def initialize
    @system_user = User.find_by!(login_name: SYSTEM_USER_LOGIN_NAME)
  end

  def post_warning
    question_ids = extract_inactive_questions_to_warn
    question_ids.each do |question_id|
      create_warning_message(question_id)
    end
  end

  def close_inactive_questions
    question_ids = extract_inactive_questions_to_close
    question_ids.each do |question_id|
      create_auto_close_message(question_id)
    end
  end

  private

  def extract_inactive_questions_to_warn
    base_time = 1.month.ago
    answers_summary = Answer
                      .select(
                        :question_id,
                        'MAX(updated_at) AS last_answer_updated_at',
                        "BOOL_OR(type = 'CorrectAnswer') AS solved"
                      )
                      .group(:question_id)
    Question
      .with(answers_summary:)
      .left_outer_joins(:answers_summary)
      .where(wip: false)
      .where('COALESCE(answers_summary.solved, false) = false')
      .where('questions.updated_at <= ?', base_time)
      .where('answers_summary.last_answer_updated_at IS NULL OR answers_summary.last_answer_updated_at <= ?', base_time)
      .ids
  end

  def extract_inactive_questions_to_close
    answers_summary = Answer
                      .select(
                        :question_id,
                        'MAX(updated_at) AS last_answer_updated_at',
                        Answer.sanitize_sql_array(['MAX(CASE WHEN user_id = ? AND description = ? THEN updated_at END) AS last_warning_at',
                                                   @system_user.id, WARNING_MESSAGE]),
                        "BOOL_OR(type = 'CorrectAnswer') AS solved"
                      )
                      .group(:question_id)
    Question
      .with(answers_summary:)
      .left_outer_joins(:answers_summary)
      .where(wip: false)
      .where('COALESCE(answers_summary.solved, false) = false')
      .where('answers_summary.last_warning_at IS NOT NULL')
      .where('answers_summary.last_warning_at <= ?', 1.week.ago)
      .where('answers_summary.last_answer_updated_at = answers_summary.last_warning_at')
      .where('questions.updated_at <= answers_summary.last_warning_at')
      .ids
  end

  def create_warning_message(question_id)
    answer = Answer.create!(question_id:, user: @system_user, description: WARNING_MESSAGE)
    ActiveSupport::Notifications.instrument('answer.create', answer:)
  end

  def create_auto_close_message(question_id)
    answer = CorrectAnswer.create!(question_id:, user: @system_user, description: AUTO_CLOSE_MESSAGE)
    ActiveSupport::Notifications.instrument('answer.save', answer:, action: "#{self.class.name}##{__method__}")
    ActiveSupport::Notifications.instrument('correct_answer.save', answer:)
  end
end
