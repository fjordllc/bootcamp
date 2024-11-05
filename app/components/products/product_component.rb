# frozen_string_literal: true

class Products::ProductComponent < ViewComponent::Base
  def initialize(product:, is_mentor:, current_user_id:, display_user_icon: true)
    @product = product
    @is_mentor = is_mentor
    @current_user_id = current_user_id
    @display_user_icon = display_user_icon
  end

  def role_class
    "is-#{@product.user.primary_role}"
  end

  def practice_title
    "#{@product.practice.title}の提出物"
  end

  def not_responded_sign?
    @product.comments.empty? ||
      (@product.self_last_commented_at &&
        (!@product.mentor_last_commented_at || @product.self_last_commented_at > @product.mentor_last_commented_at))
  end

  def until_next_elapsed_days
    elapsed_times = calc_elapsed_times
    ((elapsed_times.ceil - elapsed_times) * 24).floor
  end

  def calc_elapsed_times
    time = @product.published_at || @product.created_at
    ((Time.zone.now - time) / 1.day).to_f
  end

  def last_commented_at
    @product.comments&.last&.created_at
  end
end
