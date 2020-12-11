# frozen_string_literal: true

module BodyClassHelper
  def qualified_controller_name
    controller.controller_path.tr('/', '-')
  end

  def page_category
    case params[:action]
    when 'new', 'create', 'edit'
      'edit-page'
    when 'index'
      'index-page'
    when 'show'
      'show-page'
    else
      'other-page'
    end
  end

  def page_area
    if controller.controller_path.include?('admin/')
      'admin-page'
    elsif qualified_controller_name.include?('welcome')
      'welcome-page'
    else
      'learning-page'
    end
  end

  def admin_page?
    controller.controller_path.include?('admin/')
  end

  def body_class(options = {})
    extra_body_classes_symbol = options[:extra_body_classes_symbol] || :extra_body_classes
    qualified_controller_name = controller.controller_path.tr('/', '-')
    basic_body_class = "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name} is-#{page_category} is-#{page_area} is-#{Rails.env}"

    if content_for?(extra_body_classes_symbol)
      [basic_body_class, content_for(extra_body_classes_symbol)].join(' ')
    else
      basic_body_class
    end
  end
end
