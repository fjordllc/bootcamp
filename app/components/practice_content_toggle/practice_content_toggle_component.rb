# frozen_string_literal: true

module PracticeContentToggle
  class PracticeContentToggleComponent < ViewComponent::Base
    def initialize(content_type:, practice:)
      @content_type = content_type
      @practice = practice
    end

    def practice_content
      case @content_type
      when :practice
        {
          id_name: 'toggle_description_body',
          title: 'プラクティスを確認',
          description: @practice.description
        }
      when :goal
        {
          id_name: 'toggle_goal_body',
          title: '終了条件を確認',
          description: @practice.goal
        }
      end
    end
  end
end
