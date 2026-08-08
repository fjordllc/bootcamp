# frozen_string_literal: true

class UserPracticeProgress
  def initialize(user)
    @user = user
  end

  def checked_product_of?(*practices)
    @user.products.where(practice: practices).any?(&:checked?)
  end

  def practices_with_checked_product
    Practice.where(products: @user.products.checked)
  end

  def practice_ids_skipped
    @user.skipped_practices.pluck(:practice_id)
  end

  private

  def practices_include_progress
    @user.course.practices.where(include_progress: true)
  end

  def required_practices_size_with_skip
    @user.course.practices.where(id: practice_ids_skipped, include_progress: true).size
  end
end
