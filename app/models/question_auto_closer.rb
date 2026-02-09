# frozen_string_literal: true

class QuestionAutoCloser
  SYSTEM_USER_LOGIN_NAME = 'pjord'
  AUTO_CLOSE_WARNING_MESSAGE = 'このQ&Aは1ヶ月間更新がありませんでした。このまま更新がなければ1週間後に自動的にクローズされます。'
  AUTO_CLOSE_MESSAGE = '自動的にクローズしました。'

  def initialize
    @system_user = User.find_by!(login_name: SYSTEM_USER_LOGIN_NAME)
  end

  def post_warning
    questions = extract_inactive_questions_to_warn
    questions.each do |question|
      create_warning_message(question)
    end
  end

  def close_inactive_questions
    questions = extract_inactive_questions_to_close
    questions.each do |question|
      create_auto_close_message(question)
    end
  end

  private

  def extract_inactive_questions_to_warn
    Question.not_wip.not_solved.find_each.filter do |question|
      should_post_warning?(question)
    end
  end

  def extract_inactive_questions_to_close
    Question.not_wip.not_solved.find_each.filter do |question|
      should_close?(question)
    end
  end

  def should_post_warning?(question)
    last_updated_answer = question.answers.order(updated_at: :desc, id: :desc).first
    last_activity_at = [last_updated_answer&.updated_at, question.updated_at].compact.max
    last_activity_at <= 1.month.ago
  end

  def create_warning_message(question)
    answer = question.answers.create!(
      user: @system_user,
      description: AUTO_CLOSE_WARNING_MESSAGE
    )
    ActiveSupport::Notifications.instrument('answer.create', answer:)
  end

  def should_close?(question)
    last_updated_answer = question.answers.order(updated_at: :desc, id: :desc).first
    return false unless last_updated_answer
    return false unless last_updated_answer.user_id == @system_user.id && last_updated_answer.description == AUTO_CLOSE_WARNING_MESSAGE

    last_warned_at = last_updated_answer.updated_at
    question.updated_at < last_warned_at && last_warned_at <= 1.week.ago
  end

  def create_auto_close_message(question)
    close_answer = CorrectAnswer.create!(question:, user: @system_user, description: AUTO_CLOSE_MESSAGE)
    publish_events(close_answer)
  end

  def publish_events(correct_answer)
    action_name = "#{self.class.name}##{__method__}"
    ActiveSupport::Notifications.instrument('answer.save', answer: correct_answer, action: action_name)
    ActiveSupport::Notifications.instrument('correct_answer.save', answer: correct_answer)
  end
end
