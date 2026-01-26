# frozen_string_literal: true

module ApplicationHelper
  def my_practice?(practice)
    return false if current_user.blank?

    [:everyone, current_user.job].include?(practice.target)
  end

  def smart_search_available?
    Switchlet.enabled?(:smart_search)
  end
end
