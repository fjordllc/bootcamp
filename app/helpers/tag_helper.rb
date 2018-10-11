# frozen_string_literal: true

module TagHelper
  def current_link(name)
    if qualified_page_name&.match?(name)
      "is-active"
    end
  end

  private
    def qualified_page_name
      "#{controller_path.tr("/", "-")}-#{controller.action_name}"
    end
end
