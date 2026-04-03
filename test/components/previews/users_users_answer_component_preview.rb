# frozen_string_literal: true

class UsersUsersAnswerComponentPreview < ViewComponent::Preview
  include PreviewHelper

  def default
    render(Users::UsersAnswerComponent.new(answer: mock_answer))
  end

  def best_answer
    render(Users::UsersAnswerComponent.new(answer: mock_answer(is_best: true)))
  end

  def solved_question
    render(Users::UsersAnswerComponent.new(answer: mock_answer(question_solved: true)))
  end

  def long_description
    render(Users::UsersAnswerComponent.new(
             answer: mock_answer(description: "#{'とても長い回答です。' * 20} 詳細な説明が含まれています。")
           ))
  end

  private

  DEFAULT_DESCRIPTION = 'Rubyでは配列を扱うメソッドが豊富に用意されています。mapやselectなどを使うことで効率的にデータを処理できます。'

  def mock_practice_for_question
    practice = OpenStruct.new(id: 1, title: 'Rubyの基礎を理解する')
    practice.define_singleton_method(:to_param) { '1' }
    practice.define_singleton_method(:persisted?) { true }
    practice.define_singleton_method(:model_name) { ActiveModel::Name.new(nil, nil, 'Practice') }
    practice
  end

  def mock_question(question_solved)
    user = build_mock_user(id: 2, login_name: 'questioner', name: '質問者', long_name: '質問者 (シツモンシャ)', icon_title: '質問者')

    question = OpenStruct.new(
      id: 1, title: 'Rubyの配列操作について', user: user,
      practice: mock_practice_for_question,
      correct_answer: question_solved ? OpenStruct.new(id: 1) : nil
    )
    question.define_singleton_method(:to_param) { '1' }
    question.define_singleton_method(:persisted?) { true }
    question.define_singleton_method(:model_name) { ActiveModel::Name.new(nil, nil, 'Question') }
    question
  end

  def mock_answer(is_best: false, question_solved: false, description: DEFAULT_DESCRIPTION)
    OpenStruct.new(
      id: 1, type: is_best ? 'CorrectAnswer' : 'Answer',
      description: description, question: mock_question(question_solved), updated_at: 2.days.ago
    )
  end
end
