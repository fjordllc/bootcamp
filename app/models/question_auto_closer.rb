# frozen_string_literal: true

class QuestionAutoCloser
  SYSTEM_USER_LOGIN = 'pjord'
  AUTO_CLOSE_WARNING_MESSAGE = 'このQ&Aは1ヶ月間コメントがありませんでした。1週間後に自動的にクローズされます。'
  AUTO_CLOSE_MESSAGE = '自動的にクローズしました。'

  class << self
    def post_warning
      system_user = User.find_by(login_name: SYSTEM_USER_LOGIN)
      return unless system_user

      questions = extract_inactive_questions_to_warn(system_user)
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

    def extract_inactive_questions_to_warn(system_user)
      Question.not_wip.not_solved.find_each.filter do |question|
        should_post_warning?(question, system_user)
      end
    end

    def extract_inactive_questions_to_close(system_user)
      Question.not_wip.not_solved.find_each.filter do |question|
        should_close?(question, system_user)
      end
    end

    def should_post_warning?(question, system_user)
      last_updated_answer = question.answers.order(updated_at: :desc, id: :desc).first
      last_activity_at = [last_updated_answer&.updated_at, question.updated_at].compact.max
      return false unless last_activity_at <= 1.month.ago

      !system_message?(question, system_user, AUTO_CLOSE_MESSAGE) &&
        !system_message?(question, system_user, AUTO_CLOSE_WARNING_MESSAGE)
    end

    def create_warning_message(question, system_user)
      answer = question.answers.create!(
        user: system_user,
        description: AUTO_CLOSE_WARNING_MESSAGE
      )
      ActiveSupport::Notifications.instrument('answer.create', answer:)
    end

    def should_close?(question, system_user)
      warning_answer = find_system_message(question, system_user, AUTO_CLOSE_WARNING_MESSAGE)
      return false unless warning_answer
      return false unless warning_answer.created_at <= 1.week.ago

      !system_message?(question, system_user, AUTO_CLOSE_MESSAGE)
    end

    def find_system_message(question, system_user, message)
      warning_answers = question.answers.select do |a|
        a.user_id == system_user.id && a.description == message
      end
      warning_answers.max_by(&:created_at)
    end

    def system_message?(question, system_user, message)
      question.answers.any? { |a| a.user_id == system_user.id && a.description == message }
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
