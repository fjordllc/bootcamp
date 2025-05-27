# frozen_string_literal: true

class QuestionAutoClose < ApplicationRecord
  SYSTEM_USER_LOGIN = 'pjord'
  AUTO_CLOSE_WARNING_MESSAGE = 'このQ&Aは1ヶ月間コメントがありませんでした。1週間後に自動的にクローズされます。'
  AUTO_CLOSE_MESSAGE = '自動的にクローズしました。'
  WARNING_MESSAGE_PATTERN = /1週間後に自動的にクローズ/
  CLOSE_MESSAGE_PATTERN = /自動的にクローズしました/
  ANY_CLOSE_MESSAGE_PATTERN = /自動的にクローズ/

  def self.post_auto_close_warning
    system_user = User.find_by(login_name: SYSTEM_USER_LOGIN)
    return unless system_user

    Question.not_solved.find_each do |question|
      next unless should_post_warning?(question, system_user)

      post_warning(question, system_user)
    end
  end

  def self.auto_close_and_select_best_answer
    system_user = User.find_by(login_name: SYSTEM_USER_LOGIN)
    return unless system_user

    Question.not_solved.find_each do |question|
      next unless should_auto_close?(question, system_user)

      close_question_with_best_answer(question, system_user)
    end
  end

  class << self
    private

    def should_post_warning?(question, system_user)
      last_activity_at = question.answers.order(created_at: :desc).first&.created_at || question.created_at
      return false unless last_activity_at <= 1.month.ago

      !system_message?(question, system_user, ANY_CLOSE_MESSAGE_PATTERN) &&
        !system_message?(question, system_user, WARNING_MESSAGE_PATTERN)
    end

    def post_warning(question, system_user)
      question.answers.create!(
        user: system_user,
        description: AUTO_CLOSE_WARNING_MESSAGE
      )
    end

    def should_auto_close?(question, system_user)
      warning_answer = find_system_message(question, system_user, WARNING_MESSAGE_PATTERN)
      return false unless warning_answer
      return false unless warning_answer.created_at <= 1.week.ago

      !system_message?(question, system_user, CLOSE_MESSAGE_PATTERN)
    end

    def find_system_message(question, system_user, pattern)
      warning_answers = question.answers.select do |a|
        a.user_id == system_user.id && a.description =~ pattern
      end
      warning_answers.max_by(&:created_at)
    end

    def system_message?(question, system_user, pattern)
      question.answers.any? { |a| a.user_id == system_user.id && a.description =~ pattern }
    end

    def close_question_with_best_answer(question, system_user)
      ActiveRecord::Base.transaction do
        remove_existing_best_answer(question)
        close_answer = create_close_message(question, system_user)
        select_as_best_answer(close_answer)
        publish_events(close_answer)
      end
    end

    def remove_existing_best_answer(question)
      existing_correct = CorrectAnswer.find_by(question_id: question.id)
      existing_correct&.destroy
    end

    def create_close_message(question, system_user)
      question.answers.create!(
        user: system_user,
        description: AUTO_CLOSE_MESSAGE
      )
    end

    def select_as_best_answer(close_answer)
      correct_answer = CorrectAnswer.new(
        id: close_answer.id,
        question_id: close_answer.question_id,
        user_id: close_answer.user_id,
        description: close_answer.description,
        created_at: close_answer.created_at,
        updated_at: Time.current
      )

      close_answer.destroy
      correct_answer.save!
      correct_answer
    end

    def publish_events(correct_answer)
      Newspaper.publish(:answer_save, { answer: correct_answer })
      Newspaper.publish(:correct_answer_save, { answer: correct_answer })
    end
  end
end
