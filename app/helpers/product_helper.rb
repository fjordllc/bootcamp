# frozen_string_literal: true

module ProductHelper
  def practice_content_for_toggle(product, content_type)
    case content_type
    when :practice
      {
        id_name: 'toggle_description_body',
        title: 'プラクティスを確認',
        description: product.practice.description
      }
    when :goal
      {
        id_name: 'toggle_goal_body',
        title: '終了条件を確認',
        description: product.practice.goal
      }
    end
  end
end
