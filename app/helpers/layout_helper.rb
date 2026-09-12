# frozen_string_literal: true

module LayoutHelper
  def display_header?
    current_user && body_class.exclude?('no-header')
  end

  def display_global_nav?
    current_user && body_class.exclude?('no-global-nav')
  end

  def display_footer?
    body_class.exclude?('no-footer')
  end
end
