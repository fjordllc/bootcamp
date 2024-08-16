# frozen_string_literal: true

class SkippedPracticeComponent < ViewComponent::Base
  def initialize(form:, user:)
    @f = form
    @user = user
  end

  def skipped_practices_count(category)
    skipped_practices_in_category = category.practice_ids & @user.practice_ids_skipped
    if category.practices.empty?
      '(0)'
    else
      "(#{skipped_practices_in_category.size}/#{category.practices.size})"
    end
  end
end
