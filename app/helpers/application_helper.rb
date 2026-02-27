# frozen_string_literal: true

module ApplicationHelper
  def my_practice?(practice)
    return false if current_user.blank?

    [:everyone, current_user.job].include?(practice.target)
  end

  def movie_available?
    Rails.env.local? || current_user&.admin? || Switchlet.enabled?(:movie)
  end
end
