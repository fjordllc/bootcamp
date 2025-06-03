# frozen_string_literal: true

module QuestionsHelper
  def question_card_classes(question)
    if question.correct_answer.present?
      'is-solved'
    elsif question.wip?
      'is-wip'
    else
      ''
    end
  end

  def answer_card_classes(answer)
    if answer.question.correct_answer.present?
      'is-solved'
    else
      ''
    end
  end
end
