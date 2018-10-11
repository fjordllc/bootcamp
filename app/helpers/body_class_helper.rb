# frozen_string_literal: true

module BodyClassHelper
  def qualified_controller_name
    controller.controller_path.tr("/", "-")
  end

  def page_category
    if params[:action] == "new" || params[:action] == "create" || params[:action] == "edit"
      "edit-page"
    elsif params[:action] == "index"
      "index-page"
    elsif params[:action] == "show"
      "show-page"
    end
  end

  def body_class(options = {})
    extra_body_classes_symbol = options[:extra_body_classes_symbol] || :extra_body_classes
    qualified_controller_name = controller.controller_path.tr("/", "-")
    basic_body_class = "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name} is-#{page_category}"

    if content_for?(extra_body_classes_symbol)
      [basic_body_class, content_for(extra_body_classes_symbol)].join(" ")
    else
      basic_body_class
    end
  end
end
