# frozen_string_literal: true

class Products::ProductComponent < ViewComponent::Base
  def initialize(product:, is_mentor:, is_admin:, current_user_id:, reply_deadline_days:, display_until_next_elapsed_days: false, display_user_icon: true) # rubocop:disable Metrics/ParameterLists
    @product = product
    @is_mentor = is_mentor
    @is_admin = is_admin
    @current_user_id = current_user_id
    @reply_deadline_days = reply_deadline_days
    @display_until_next_elapsed_days = display_until_next_elapsed_days
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
    ((elapsed_days.ceil - elapsed_days) * 24).floor
  end

  def elapsed_days
    time = @product.published_at || @product.created_at
    ((Time.zone.now - time) / 1.day).to_f
  end

  def last_checked_at
    l(@product.checks.last.created_at.to_date, format: :short)
  end

  def last_checked_user_login_name
    @product.checks.last.user.login_name
  end
end
