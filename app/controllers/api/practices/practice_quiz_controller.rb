# frozen_string_literal: true

class API::Practices::PracticeQuizController < API::BaseController # rubocop:disable Metrics/ClassLength
  skip_before_action :doorkeeper_authorize!
  prepend_before_action -> { doorkeeper_authorize! :mentor }
  before_action -> { doorkeeper_authorize! :write }, only: %i[create update destroy]
  before_action :require_admin_or_mentor_login_for_api
  before_action :set_practice

  rescue_from ActiveRecord::RecordNotFound, with: -> { render_not_found }
  rescue_from ActiveRecord::RecordNotUnique, with: :render_conflict

  def show
    quiz = @practice.practice_quiz
    return render_not_found if quiz.blank?

    render json: quiz_json(quiz)
  end

  def create
    return render_conflict if PracticeQuiz.exists?(practice_id: @practice.id)
    return unless valid_payload?

    quiz = PracticeQuiz.new(practice_quiz_params.merge(practice: @practice, published: false))
    return unless valid_questions?(quiz)

    if quiz.save
      render json: quiz_json(quiz), status: :created
    elsif quiz.errors.of_kind?(:practice_id, :taken)
      render_conflict
    else
      render_validation_errors(quiz)
    end
  end

  def update
    quiz = @practice.practice_quiz
    return render_not_found if quiz.blank?

    attributes = params[:practice_quiz]
    attributes = attributes.to_unsafe_h if attributes.is_a?(ActionController::Parameters)
    if PracticeQuizUpdate.new(quiz, attributes).save
      render json: quiz_json(quiz)
    else
      render_validation_errors(quiz)
    end
  end

  def destroy
    quiz = @practice.practice_quiz
    return render_not_found if quiz.blank?

    quiz.with_lock do
      if quiz.practice_quiz_attempts.exists?
        render json: { message: '受験履歴がある理解度テストは削除できません。' }, status: :conflict
        return
      end

      quiz.update!(published: false)
      raise ActiveRecord::RecordNotDestroyed.new('理解度テストを削除できませんでした。', quiz) unless quiz.destroy
    end
    head :no_content
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed => e
    render_validation_errors(e.record)
  end

  private

  # This endpoint's authority always comes from the OAuth owner, even with a session cookie.
  def current_user
    current_resource_owner
  end

  def set_practice
    @practice = Practice.find(params[:practice_id])
  end

  def render_conflict
    render json: { message: 'このプラクティスには理解度テストが既に存在します。' }, status: :conflict
  end

  def practice_quiz_params
    attributes = params.expect(practice_quiz: [{ practice_quiz_questions_attributes: [[
                                 :question_type, :body, :explanation, :position, :published,
                                 { practice_quiz_choices_attributes: [%i[body correct position]] }
                               ]] }])
    attributes[:practice_quiz_questions_attributes].each { |question| question.reverse_merge!(published: true) }
    attributes
  end

  def valid_payload?
    quiz = params[:practice_quiz]
    questions = quiz[:practice_quiz_questions_attributes] if quiz.is_a?(ActionController::Parameters)
    unless questions.is_a?(Array) && questions.present?
      render json: { errors: { practice_quiz_questions_attributes: ['1つ以上の問題が必要です。'] } }, status: :unprocessable_entity
      return false
    end

    errors = questions.each_with_index.flat_map { |question, index| question_attribute_errors(question, index) }
    return true if errors.empty?

    render json: { errors: { practice_quiz_questions_attributes: errors } }, status: :unprocessable_entity
    false
  end

  def question_attribute_errors(question, index)
    prefix = "問題#{index + 1}: "
    return ["#{prefix}問題の形式が不正です。"] unless question.is_a?(ActionController::Parameters)

    errors = []
    errors << "#{prefix}問題の種類が不正です。" unless PracticeQuizQuestion.question_types.key?(question[:question_type])
    errors << "#{prefix}publishedは真偽値で指定してください。" if question.key?(:published) && ![true, false].include?(question[:published])
    choices = question[:practice_quiz_choices_attributes]
    return errors + ["#{prefix}選択肢の配列が必要です。"] unless choices.is_a?(Array)

    choices.each_with_index do |choice, choice_index|
      error = choice_attribute_error(choice)
      errors << "#{prefix}選択肢#{choice_index + 1}: #{error}" if error
    end
    errors
  end

  def choice_attribute_error(choice)
    return '本文が必要です。' unless choice.is_a?(ActionController::Parameters) && choice[:body].is_a?(String) && choice[:body].present?
    return 'correctは真偽値で指定してください。' if choice.key?(:correct) && ![true, false].include?(choice[:correct])

    nil
  end

  def valid_questions?(quiz)
    quiz.practice_quiz_questions.each_with_index do |question, index|
      published = question.published
      # Reuse the domain's complete-choice validation for unpublished questions too.
      question.published = true
      question.valid?
      question.errors.full_messages.each { |message| quiz.errors.add(:base, "問題#{index + 1}: #{message}") }
      question.published = published
    end
    return true if quiz.errors.empty?

    render_validation_errors(quiz)
    false
  end

  def quiz_json(quiz)
    {
      id: quiz.id, practice_id: quiz.practice_id, published: quiz.published,
      questions: quiz.practice_quiz_questions.includes(:practice_quiz_choices).map do |question|
        {
          id: question.id, question_type: question.question_type, body: question.body, explanation: question.explanation,
          position: question.position, published: question.published,
          choices: question.practice_quiz_choices.map do |choice|
            { id: choice.id, body: choice.body, correct: choice.correct, position: choice.position }
          end
        }
      end
    }
  end
end
