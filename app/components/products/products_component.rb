# frozen_string_literal: true

class Products::ProductsComponent < ViewComponent::Base
  def initialize(products:, products_grouped_by_elapsed_days:, is_mentor:, current_user_id:, reply_warning_days:)
    @products = products
    @products_grouped_by_elapsed_days = products_grouped_by_elapsed_days
    @is_mentor = is_mentor
    @current_user_id = current_user_id
    @reply_warning_days = reply_warning_days
    @reply_alert_days = @reply_warning_days + 1
    @reply_deadline_days = @reply_warning_days + 2
  end

  def any_products_elapsed_reply_warning_days?
    elapsed_days = @products_grouped_by_elapsed_days.keys
    elapsed_days.all? { |day| day < @reply_warning_days }
  end

  def count_products_grouped_by(products_n_days_passed)
    products_n_days_passed.length
  end

  def elapsed_days_class(elapsed_days)
    case elapsed_days
    when @reply_warning_days
      'is-reply-warning'
    when @reply_alert_days
      'is-reply-alert'
    when @reply_deadline_days
      'is-reply-deadline'
    else
      ''
    end
  end

  def elapsed_days_text(elapsed_days)
    if elapsed_days.zero?
      '今日提出'
    elsif elapsed_days >= @reply_deadline_days
      "#{elapsed_days}日以上経過"
    else
      "#{elapsed_days}日経過"
    end
  end

  def elapsed_days_id(elapsed_days)
    "#{elapsed_days}days-elapsed"
  end

  def count_almost_passed_reply_warning_days
    one_day_before_reply_warning_days = @reply_warning_days - 1
    products_passed_one_day_before_reply_warning_days = @products_grouped_by_elapsed_days[one_day_before_reply_warning_days]
    return 0 unless products_passed_one_day_before_reply_warning_days

    passed_almost_reply_warning_days_products(products_passed_one_day_before_reply_warning_days).length
  end

  private

  def passed_almost_reply_warning_days_products(products)
    products.select do |product|
      threshold_day = @reply_warning_days
      threshold_hour = 8
      (threshold_day - elapsed_times(product)) * 24 <= threshold_hour
    end
  end

  def elapsed_times(product)
    last_submitted_time = product.published_at || product.created_at
    (Time.zone.now - last_submitted_time) / 1.day
  end
end
