# frozen_string_literal: true

module LearningHelper
  def complete_all_practices_in_category(user, category)
    category.practices.each do |practice|
      set_learning_status(user, practice, :complete)
    end
  end

  def set_learning_status(user, practice, status)
    Learning.find_or_initialize_by(user:, practice:).tap { |l| l.update!(status:) }
  end
end
