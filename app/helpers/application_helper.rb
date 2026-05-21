# frozen_string_literal: true

module ApplicationHelper
  def link_to(name = nil, options = nil, html_options = nil, &block)
    if block
      html_options = options
      options = name
    end

    html_options = convert_legacy_link_options(html_options)

    if block
      super(options, html_options, &block)
    else
      super(name, options, html_options)
    end
  end

  def form_with(**options, &block)
    if options[:local]
      data = (options[:data] || {}).to_h
      data[:turbo] = false unless data.key?(:turbo) || data.key?('turbo')
      options[:data] = data
    end

    super(**options, &block)
  end

  def my_practice?(practice)
    return false if current_user.blank?

    [:everyone, current_user.job].include?(practice.target)
  end

  def movie_available?
    Rails.env.local? || current_user&.admin? || Switchlet.enabled?(:movie)
  end

  def pair_work_available?
    Rails.env.local? || Switchlet.enabled?(:pair_work)
  end

  private

  def convert_legacy_link_options(html_options)
    return html_options unless html_options.is_a?(Hash)

    html_options = html_options.dup
    method = html_options.delete(:method)
    confirm = html_options.delete(:confirm) || html_options.dig(:data, :confirm) || html_options.dig(:data, 'confirm')
    data = legacy_link_data(html_options[:data], method, confirm)
    html_options[:data] = data if data
    html_options[:onclick] ||= 'return window.submitLegacyMethodLink(this, event)' if method.present?
    html_options
  end

  def legacy_link_data(current_data, method, confirm)
    return if method.blank? && confirm.blank?

    data = (current_data || {}).to_h
    add_turbo_data(data, :turbo_method, method)
    add_turbo_data(data, :turbo_confirm, confirm)
    data.delete(:confirm)
    data.delete('confirm')
    data
  end

  def add_turbo_data(data, key, value)
    return if value.blank? || data.key?(key) || data.key?(key.to_s)

    data[key] = value
  end
end
