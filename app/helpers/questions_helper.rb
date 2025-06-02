# frozen_string_literal: true

module QuestionsHelper
  def question_css_class(question)
    if question.has_correct_answer?
      'is-solved'
    elsif question.wip?
      'is-wip'
    else
      ''
    end
  end

  def question_urgency_css_class(question)
    question.answers.empty? ? 'is-important' : ''
  end

  def user_role_css_class(user)
    "is-#{user.primary_role}"
  end
end