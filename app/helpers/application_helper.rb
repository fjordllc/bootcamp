# frozen_string_literal: true

module ApplicationHelper
  def my_practice?(practice)
    return false if current_user.blank?

    [:everyone, current_user.job].include?(practice.target)
  end

  # スマート検索機能が利用可能かどうかを判定
  # development環境: 常に有効
  # production環境: adminユーザーのみ有効
  def smart_search_available?
    return true if Rails.env.development?
    return true if Rails.env.test? && Switchlet.enabled?(:smart_search)

    current_user&.admin?
  end
end
