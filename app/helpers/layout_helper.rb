# frozen_string_literal: true

module LayoutHelper
  def display_header?
    current_user && body_class.exclude?('no-header')
  end

  def display_global_nav?
    current_user && body_class.exclude?('no-global-nav')
  end

  def display_recent_reports?
    logged_in? && body_class.exclude?('no-recent-reports') && !admin_page? && body_class.exclude?('is-edit-page')
  end

  def display_footer?
    body_class.exclude?('no-footer')
  end

  def category_having_active_practice
    active_practice = current_user.active_practices.first
    active_practice.categories.first
  end

  def category_having_unstarted_practice
    unstarted_practice = current_user.unstarted_practices.first
    unstarted_practice.categories.first
  end

  def category_active_or_unstarted_practice
    if current_user.active_practices.present?
      category_having_active_practice
    elsif current_user.unstarted_practices.present?
      category_having_unstarted_practice
    end
  end
end


