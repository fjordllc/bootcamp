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
      description: 'とても長い回答です。' * 20 + ' 詳細な説明が含まれています。'
    )

    render(Users::UsersAnswerComponent.new(answer: answer))
  end

  private

  def mock_answer(is_best: false, question_solved: false, description: 'Rubyでは配列を扱うメソッドが豊富に用意されています。mapやselectなどを使うことで効率的にデータを処理できます。')
    question_user = OpenStruct.new(
      id: 2,
      login_name: 'questioner',
      name: '質問者',
      primary_role: 'student',
      avatar_url: 'https://via.placeholder.com/40',
      icon_title: '質問者'
    )

    question = OpenStruct.new(
      id: 1,
      title: 'Rubyの配列操作について',
      user: question_user,
      correct_answer: question_solved ? OpenStruct.new(id: 1) : nil
    )

    OpenStruct.new(
      id: 1,
      type: is_best ? 'CorrectAnswer' : 'Answer',
      description: description,
      question: question,
      updated_at: 2.days.ago
    )
  end
end