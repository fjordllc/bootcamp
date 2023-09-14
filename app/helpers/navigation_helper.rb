# frozen_string_literal: true

module NavigationHelper
  def current_link(name)
    return unless qualified_page_name&.match?(name)

    'is-active'
  end

  def qualified_page_name
    "#{qualified_controller_name}-#{action_name}"
  end
end
