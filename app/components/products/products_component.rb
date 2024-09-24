# frozen_string_literal: true

class Products::ProductsComponent < ViewComponent::Base
  def initialize(products:, products_grouped_by_elapsed_days:, is_mentor:, current_user_id:, display_user_icon: true)
    @products = products
    @products_grouped_by_elapsed_days = products_grouped_by_elapsed_days
    @is_mentor = is_mentor
    @current_user_id = current_user_id
    @display_user_icon = display_user_icon
  end

  def any_products_5days_elapsed?
    elapsed_days = @products_grouped_by_elapsed_days.keys
    elapsed_days.all? { |day| day < 5 }
  end

  def count_products_grouped_by(products_n_days_passed)
    products_n_days_passed.length
  end

  def elapsed_days_class(elapsed_days)
    case elapsed_days
    when 5
      'is-reply-warning'
    when 6
      'is-reply-alert'
    when 7
      'is-reply-deadline'
    else
      ''
    end
  end

  def elapsed_days_text(elapsed_days)
    if elapsed_days.zero?
      '今日提出'
    elsif elapsed_days >= 7
      "#{elapsed_days}日以上経過"
    else
      "#{elapsed_days}日経過"
    end
  end

  def elapsed_days_id(elapsed_days)
    "#{elapsed_days}days-elapsed"
  end

  def count_almost_passed_5days
    products_passed_4days = @products_grouped_by_elapsed_days[4]
    return 0 unless products_passed_4days

    passed_almost_5days_products(products_passed_4days).length
  end

  private

  def passed_almost_5days_products(products)
    products.select do |product|
      threshold_day = 5
      threshold_hour = 8
      (threshold_day - elapsed_times(product)) * 24 <= threshold_hour
    end
  end

  def elapsed_times(product)
    last_submitted_time = product.published_at || product.created_at
    (Time.zone.now - last_submitted_time) / 1.day
  end
end
