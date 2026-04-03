# frozen_string_literal: true

class LearningsLearningComponentPreview < ViewComponent::Preview
  def default
    practice = mock_practice('Rubyの基礎を理解する')
    current_user = mock_user

    render(Learnings::LearningComponent.new(
             practice: practice,
             current_user: current_user
           ))
  end

  def with_submission
    practice = mock_practice('Linuxの基礎を理解する', submission: true)
    current_user = mock_user

    render(Learnings::LearningComponent.new(
             practice: practice,
             current_user: current_user
           ))
  end

  private

  def mock_practice(title, submission: false)
    practice = OpenStruct.new(
      id: 1,
      title: title,
      submission?: submission
    )
    practice.define_singleton_method(:product) { |_user| nil }
    practice
  end

  def mock_user
    user = OpenStruct.new(
      id: 1,
      login_name: 'yamada'
    )
    user.define_singleton_method(:completed?) { |_practice| false }
    user
  end
end
