# frozen_string_literal: true

class UsersUsersAnswerComponentPreview < ViewComponent::Preview
  def default
    answer = mock_answer

    render(Users::UsersAnswerComponent.new(answer: answer))
  end

  def best_answer
    answer = mock_answer(is_best: true)

    render(Users::UsersAnswerComponent.new(answer: answer))
  end

  def solved_question
    answer = mock_answer(question_solved: true)

    render(Users::UsersAnswerComponent.new(answer: answer))
  end

  def long_description
    answer = mock_answer(
      description: "#{'とても長い回答です。' * 20} 詳細な説明が含まれています。"
    )

    render(Users::UsersAnswerComponent.new(answer: answer))
  end

  private

  DEFAULT_DESCRIPTION = 'Rubyでは配列を扱うメソッドが豊富に用意されています。mapやselectなどを使うことで効率的にデータを処理できます。'

  def mock_question_user
    user = OpenStruct.new(
      id: 2, login_name: 'questioner', name: '質問者', long_name: '質問者 (シツモンシャ)',
      primary_role: 'student', avatar_url: 'https://via.placeholder.com/40', icon_title: '質問者',
      user_icon_frame_class: 'a-user-role is-student'
    )
    user.define_singleton_method(:icon_classes) { |image_class| ['a-user-icon', image_class].compact.join(' ') }
    user.define_singleton_method(:to_param) { 'questioner' }
    user.define_singleton_method(:persisted?) { true }
    user.define_singleton_method(:model_name) { OpenStruct.new(route_key: 'users', singular_route_key: 'user') }
    user
  end

  def mock_question(question_solved)
    practice = OpenStruct.new(id: 1, title: 'Rubyの基礎を理解する')
    practice.define_singleton_method(:to_param) { '1' }
    practice.define_singleton_method(:persisted?) { true }
    practice.define_singleton_method(:model_name) { OpenStruct.new(route_key: 'practices', singular_route_key: 'practice') }

    question = OpenStruct.new(
      id: 1, title: 'Rubyの配列操作について', user: mock_question_user,
      practice: practice,
      correct_answer: question_solved ? OpenStruct.new(id: 1) : nil
    )
    question.define_singleton_method(:to_param) { '1' }
    question.define_singleton_method(:persisted?) { true }
    question.define_singleton_method(:model_name) { OpenStruct.new(route_key: 'questions', singular_route_key: 'question') }
    question
  end

  def mock_answer(is_best: false, question_solved: false, description: DEFAULT_DESCRIPTION)
    OpenStruct.new(
      id: 1, type: is_best ? 'CorrectAnswer' : 'Answer',
      description: description, question: mock_question(question_solved), updated_at: 2.days.ago
    )
  end
end
