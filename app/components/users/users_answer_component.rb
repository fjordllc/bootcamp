# frozen_string_literal: true

class Users::UsersAnswerComponent < ViewComponent::Base
  def initialize(answer:)
    @answer = answer
  end

  def answer_class
    if answer.question.correct_answer.present?
      'is-solved'
    else
      ''
    end
  end

  def role_class
    "is-#{answer.question.user.primary_role}"
  end

  def formatted_updated_at
    l(answer.updated_at, format: :default)
  end

  def summary
    description = answer.description
    if description.length <= 90
      description
    else
      "#{description[0..89]}..."
    end
  end

  def best_answer?
    answer.type == 'CorrectAnswer'
  end

  def question_user_avatar
    image_tag(
      answer.question.user.avatar_url,
      title: answer.question.user.icon_title,
      alt: answer.question.user.icon_title,
      class: 'card-list-item__user-icon a-user-icon'
    )
  end

  private

  attr_reader :answer
end
