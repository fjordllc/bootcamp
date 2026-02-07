# frozen_string_literal: true

class QuestionAutoCloser
  SYSTEM_USER_LOGIN = 'pjord'
  AUTO_CLOSE_WARNING_MESSAGE = 'このQ&Aは1ヶ月間更新がありませんでした。このまま更新がなければ1週間後に自動的にクローズされます。'
  AUTO_CLOSE_MESSAGE = '自動的にクローズしました。'

  class << self
    def post_warning
      system_user = User.find_by(login_name: SYSTEM_USER_LOGIN)
      return unless system_user

      questions = extract_inactive_questions_to_warn
      questions.each do |question|
        create_warning_message(question, system_user)
      end
    end

    def close_and_select_best_answer
      system_user = User.find_by(login_name: SYSTEM_USER_LOGIN)
      return unless system_user

      questions = extract_inactive_questions_to_close(system_user)
      questions.each do |question|
        close_with_best_answer(question, system_user)
      end
    end

    private

    def extract_inactive_questions_to_warn
      Question.not_wip.not_solved.find_each.filter do |question|
        should_post_warning?(question)
      end
    end

    def extract_inactive_questions_to_close(system_user)
      Question.not_wip.not_solved.find_each.filter do |question|
        should_close?(question, system_user)
      end
    end

    def should_post_warning?(question)
      last_updated_answer = question.answers.order(updated_at: :desc, id: :desc).first
      last_activity_at = [last_updated_answer&.updated_at, question.updated_at].compact.max
      last_activity_at <= 1.month.ago
    end

    def create_warning_message(question, system_user)
      answer = question.answers.create!(
        user: system_user,
        description: AUTO_CLOSE_WARNING_MESSAGE
      )
      ActiveSupport::Notifications.instrument('answer.create', answer:)
    end

    def should_close?(question, system_user)
      last_updated_answer = question.answers.order(updated_at: :desc, id: :desc).first
      return false unless last_updated_answer
      return false unless last_updated_answer.user_id == system_user.id && last_updated_answer.description == AUTO_CLOSE_WARNING_MESSAGE

      last_warned_at = last_updated_answer.updated_at
      question.updated_at < last_warned_at && last_warned_at <= 1.week.ago
    end

    def close_with_best_answer(question, system_user)
      close_answer = CorrectAnswer.create!(question:, user: system_user, description: AUTO_CLOSE_MESSAGE)
      publish_events(close_answer)
    end

    def publish_events(correct_answer)
      action_name = "#{name}.#{__method__}"
      ActiveSupport::Notifications.instrument('answer.save', answer: correct_answer, action: action_name)
      ActiveSupport::Notifications.instrument('correct_answer.save', answer: correct_answer)
    end
  end
end
