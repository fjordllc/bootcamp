# frozen_string_literal: true

module PageTabHelper
  def page_tab_members(resource)
    case resource
    when Practice
      practices_tab_members(resource)
    when User
      users_tab_members(resource)
    end
  end

  def current_page_tab_or_not(target_name)
    current_page_tab?(target_name) ? 'is-active' : ''
  end

  def users_current_page_tab_or_not(target_name)
    users_current_page_tab?(target_name) ? 'is-active' : ''
  end

  private

  def practices_tab_members(resource)
    [
      root_tab(resource),
      reports_tab(resource),
      questions_tab(resource),
      pages_tab(resource),
      products_tab(resource)
    ]
  end

  def root_tab(resource)
    page_tab_member(resource, resource.class.name.tableize.to_sym)
  end

  def page_tab_member(path, tab_name, is_products_tab: false)
    {
      path:,
      target_name: tab_name.to_s,
      display_name: display_tab_name(tab_name),
      is_products_tab:
    }
  end

  def display_tab_name(tab_name)
    display_tab_names[tab_name]
  end

  def display_tab_names
    {
      practices: 'プラクティス',
      reports: '日報',
      questions: '質問',
      pages: 'Docs',
      products: '提出物'
    }
  end

  def reports_tab(resource)
    tab_name = :reports
    page_tab_member(tab_path(resource, tab_name), tab_name)
  end

  def tab_path(resource, tab_name)
    [resource, tab_name]
  end

  def questions_tab(resource)
    tab_name = :questions
    page_tab_member(tab_path(resource, tab_name), tab_name)
  end

  def products_tab(resource)
    tab_name = :products
    page_tab_member(tab_path(resource, tab_name), tab_name, is_products_tab: true)
  end

  def comments_tab(resource)
    tab_name = :comments
    page_tab_member(tab_path(resource, tab_name), tab_name)
  end

  def pages_tab(resource)
    tab_name = :pages
    page_tab_member(tab_path(resource, tab_name), tab_name)
  end

  def current_page_tab?(target_name)
    paths = url_for(only_path: false).split('/')
    if paths[-2] == target_name
      true
    else
      paths.last == target_name
    end
  end

  def users_current_page_tab?(target_name)
    paths = url_for(only_path: false).split('/')
    paths.last == target_name
  end
end
