# frozen_string_literal: true

module ApplicationHelper
  def my_practice?(practice)
    return false if current_user.blank?

    [:everyone, current_user.job].include?(practice.target)
  end

  # development/test環境では常に有効、それ以外はフィーチャーフラグで制御
  def smart_search_available?
    Rails.env.local? || Switchlet.enabled?(:smart_search)
  end

  def movie_available?
    Rails.env.local? || Switchlet.enabled?(:movie)
  end
end
