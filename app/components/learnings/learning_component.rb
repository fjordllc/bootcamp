# frozen_string_literal: true

class Learnings::LearningComponent < ViewComponent::Base
  def initialize(practice:, current_user:)
    @practice = practice
    @current_user = current_user
    @learning = Learning.find_or_initialize_by(
      user_id: @current_user.id,
      practice_id: @practice.id
    )
    @learning.status = :unstarted if @learning.new_record?
    @product = @practice.product(@current_user)
  end

  def product_link
    @product ? product_path(@product) : new_product_path(practice_id: @practice.id)
  end

  def product_label
    @product ? '提出物へ' : '提出物を作る'
  end

  def submission?
    @practice.submission
  end
end
