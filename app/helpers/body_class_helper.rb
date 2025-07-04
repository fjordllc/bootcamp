# frozen_string_literal: true

module BodyClassHelper
  def qualified_controller_name
    controller_path.tr('/', '-')
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

  def adviser_mode
    'is-adviser-mode' if adviser_login?
  end

  def page_area
    if admin_page?
      'admin-page'
    elsif qualified_controller_name.include?('welcome') ||
          (qualified_controller_name.include?('articles') && %w[index-page show-page].include?(page_category))
      'welcome-page'
    else
      'learning-page'
    end
  end

  def admin_page?
    controller_path.include?('admin/')
  end

  def controller_class
    "is-#{qualified_controller_name} is-#{qualified_page_name}"
  end

  def body_class(options = {})
    extra_body_classes_symbol = options[:extra_body_classes_symbol] || :extra_body_classes
    basic_body_class = "#{controller_class} is-#{page_category} is-#{page_area} is-#{Rails.env} #{adviser_mode}"

    if content_for?(extra_body_classes_symbol)
      [basic_body_class, content_for(extra_body_classes_symbol)].join(' ')
    else
      basic_body_class
    end
  end
end
