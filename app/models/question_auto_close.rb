# frozen_string_literal: true

class QuestionAutoClose < ApplicationRecord
  def self.post_auto_close_warning
    system_user = User.find_by(login_name: 'pjord')
    return unless system_user

    Question.not_solved.find_each do |question|
      last_activity_at = question.answers.order(created_at: :desc).first&.created_at || question.created_at
      next unless last_activity_at <= 1.month.ago
      next if question.answers.any? { |a| a.user == system_user && a.description =~ /自動的にクローズ/ }
      next if question.answers.any? { |a| a.user == system_user && a.description =~ /1週間後に自動的にクローズ/ }

      question.answers.create!(
        user: system_user,
        description: 'このQ&Aは1ヶ月間コメントがありませんでした。1週間後に自動的にクローズされます。'
      )
    end
  end

  def self.auto_close_and_select_best_answer
    system_user = User.find_by(login_name: 'pjord')
    return unless system_user

    question_count = 0

    Rails.logger.info '=== 自動クローズ処理を開始します ==='

    Question.not_solved.find_each do |question|
      warning_answers = question.answers.select do |a|
        a.user_id == system_user.id && a.description =~ /1週間後に自動的にクローズ/
      end

      warning_answer = warning_answers.max_by(&:created_at)
      unless warning_answer
        Rails.logger.info "質問 ID: #{question.id} - 警告回答がないためスキップします"
        next
      end

      # unless warning_answer.created_at <= 1.week.ago
      #   Rails.logger.info "質問 ID: #{question.id} - 警告回答から1週間経過していないためスキップします (#{warning_answer.created_at})"
      #   next
      # end
      Rails.logger.info "質問 ID: #{question.id} - 警告回答があります。経過期間チェックを無視して処理を続行します (#{warning_answer.created_at})"

      if question.answers.any? { |a| a.user_id == system_user.id && a.description =~ /自動的にクローズしました/ }
        Rails.logger.info "質問 ID: #{question.id} - すでにクローズ済みのためスキップします"
        next
      end

      user_answers = question.answers.reject { |a| a.user_id == system_user.id }
                             .reject { |a| a.description =~ /自動的にクローズ|1週間後に自動的にクローズ/ }

      last_user_answer = user_answers.max_by(&:created_at)
      unless last_user_answer
        Rails.logger.info "質問 ID: #{question.id} - ユーザーからの回答がないためスキップします"
        next
      end

      Rails.logger.info "質問 ID: #{question.id} - 自動クローズ条件を満たしています。処理を開始します"
      Rails.logger.info "選択する回答 ID: #{last_user_answer.id}, ユーザー: #{last_user_answer.user_id}"

      ActiveRecord::Base.transaction do
        existing_correct = CorrectAnswer.find_by(question_id: question.id)
        existing_correct&.destroy

        correct_answer = CorrectAnswer.new(
          id: last_user_answer.id,
          question_id: last_user_answer.question_id,
          user_id: last_user_answer.user_id,
          description: last_user_answer.description,
          created_at: last_user_answer.created_at,
          updated_at: Time.current
        )

        last_user_answer.destroy
        correct_answer.save!

        Newspaper.publish(:answer_save, { answer: correct_answer })
        Newspaper.publish(:correct_answer_save, { answer: correct_answer })

        question.answers.create!(
          user: system_user,
          description: '自動的にクローズしました。'
        )

        question_count += 1
        Rails.logger.info "質問 ID: #{question.id} - 自動クローズが完了しました"
      end
    rescue StandardError => e
      Rails.logger.error "質問 ID: #{question.id} - 自動クローズ処理中にエラーが発生しました: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end

    Rails.logger.info "=== 自動クローズ処理が完了しました。#{question_count}件の質問をクローズしました ==="
    question_count
  end
end
