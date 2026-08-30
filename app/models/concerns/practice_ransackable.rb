# frozen_string_literal: true

module PracticeRansackable
  extend ActiveSupport::Concern

  class_methods do
    def ransackable_attributes(_auth_object = nil)
      %w[title description goal created_at updated_at last_updated_user_id submission]
    end

    def ransackable_associations(_auth_object = nil)
      %w[learnings categories products questions pages movies books last_updated_user]
    end
  end
end
