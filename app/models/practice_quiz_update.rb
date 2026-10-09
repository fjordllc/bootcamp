# frozen_string_literal: true

# Applies partial API updates without changing the web UI's nested-attribute rules.
class PracticeQuizUpdate
  def initialize(quiz, attributes)
    @quiz = quiz
    @attributes = attributes.is_a?(Hash) ? attributes.deep_symbolize_keys : attributes
  end

  def save
    @quiz.errors.clear
    payload_errors.each { |message| @quiz.errors.add(:practice_quiz, message) }
    return false if @quiz.errors.any?

    @quiz.with_lock do
      published = @attributes.fetch(:published, @quiz.published)
      # Domain publication checks query persisted rows. Save nested edits as a
      # draft, then restore publication inside the same transaction and row lock.
      @quiz.published = false
      @quiz.assign_attributes(nested_attributes)
      validate_questions
      validate_publication(published)
      raise ActiveRecord::RecordInvalid, @quiz if @quiz.errors.any?

      @quiz.save!
      @quiz.reload.update!(published:)
    end
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed => e
    e.record.errors.full_messages.each { |message| @quiz.errors.add(:base, message) } unless e.record == @quiz
    @quiz.errors.add(:base, '理解度テストを更新できませんでした。') if @quiz.errors.empty?
    false
  end

  private

  def payload_errors
    return ['理解度テストの形式が不正です。'] unless @attributes.is_a?(Hash)

    errors = boolean_errors(@attributes, %i[published])
    return errors unless @attributes.key?(:practice_quiz_questions_attributes)

    questions = @attributes[:practice_quiz_questions_attributes].presence
    return errors + ['問題の配列が必要です。'] unless questions.is_a?(Array)

    errors + questions.flat_map { |question| question_errors(question) }
  end

  def question_errors(attributes)
    return ['問題の形式が不正です。'] unless attributes.is_a?(Hash)

    errors = boolean_errors(attributes, %i[published _destroy]) + id_errors(attributes)
    if (!attributes.key?(:id) || attributes.key?(:question_type)) && !PracticeQuizQuestion.question_types.key?(attributes[:question_type])
      errors << '問題の種類が不正です。'
    end
    return errors unless attributes.key?(:practice_quiz_choices_attributes)

    choices = attributes[:practice_quiz_choices_attributes].presence
    return errors + ['選択肢の配列が必要です。'] unless choices.is_a?(Array)

    errors + choices.flat_map { |choice| choice_errors(choice) }
  end

  def choice_errors(attributes)
    return ['選択肢の形式が不正です。'] unless attributes.is_a?(Hash)

    errors = boolean_errors(attributes, %i[correct _destroy]) + id_errors(attributes)
    if !(attributes[:_destroy] == true || (attributes.key?(:id) && !attributes.key?(:body))) && !(attributes[:body].is_a?(String) && attributes[:body].present?)
      errors << '選択肢の本文が必要です。'
    end
    errors
  end

  def boolean_errors(attributes, keys)
    keys.filter_map { |key| "#{key}は真偽値で指定してください。" if attributes.key?(key) && ![true, false].include?(attributes[key]) }
  end

  def id_errors(attributes)
    return [] unless attributes.key?(:id)
    return [] if attributes[:id].is_a?(Integer) || (attributes[:id].is_a?(String) && attributes[:id].match?(/\A\d+\z/))

    ['IDの形式が不正です。']
  end

  def nested_attributes
    @quiz.practice_quiz_questions.load
    questions = @attributes.fetch(:practice_quiz_questions_attributes, []).map do |attributes|
      question = (@quiz.practice_quiz_questions.find { |row| row.id.to_s == attributes[:id].to_s } if attributes.key?(:id))
      raise ActiveRecord::RecordNotFound if attributes.key?(:id) && question.nil?

      permitted = attributes.slice(:id, :question_type, :body, :explanation, :position, :published, :_destroy)
      permitted.reverse_merge!(published: true) unless question
      if attributes.key?(:practice_quiz_choices_attributes)
        permitted[:practice_quiz_choices_attributes] = choice_attributes(question, attributes[:practice_quiz_choices_attributes])
      end
      permitted
    end
    { practice_quiz_questions_attributes: questions }
  end

  def choice_attributes(question, choices)
    question&.practice_quiz_choices&.load
    choices.map do |attributes|
      permitted = attributes.slice(:id, :body, :correct, :position, :_destroy)
      if attributes.key?(:id)
        choice = question&.practice_quiz_choices&.find { |row| row.id.to_s == attributes[:id].to_s }
        raise ActiveRecord::RecordNotFound unless choice

        # UI reject_if considers an omitted body blank; retain it for partial edits.
        permitted.reverse_merge!(body: choice.body)
      end
      permitted
    end
  end

  def validate_questions
    @quiz.practice_quiz_questions.each_with_index do |question, index|
      next if question.marked_for_destruction?

      published = question.published
      question.published = true
      question.valid?
      question.errors.full_messages.each { |message| @quiz.errors.add(:base, "問題#{index + 1}: #{message}") }
      question.published = published
    end
  end

  def validate_publication(published)
    return unless published && @quiz.practice_quiz_questions.none? { |question| !question.marked_for_destruction? && question.published? }

    @quiz.errors.add(:base, '公開中の理解度テストには公開中の問題が必要です。')
  end
end
