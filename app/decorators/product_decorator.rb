# frozen_string_literal: true

module ProductDecorator
  def list_title(resource)
    case resource
    when Practice
      user.login_name
    when User
      practice.title
    end
  end

  def practice_content_for_toggle(content_type)
    case content_type
    when :practice
      {
        id_name: 'toggle_description_body',
        title: 'プラクティスを確認',
        description: practice.description
      }
    when :goal
      {
        id_name: 'toggle_goal_body',
        title: '終了条件を確認',
        description: practice.goal
      }
    end
  end
end
