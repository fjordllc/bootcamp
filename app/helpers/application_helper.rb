# frozen_string_literal: true

module ApplicationHelper
  def li_for(record, prefix = nil, options = nil, &block)
    content_tag_for(:li, record, prefix, options, &block)
  end

  def tr_for(record, prefix = nil, options = nil, &block)
    content_tag_for(:tr, record, prefix, options, &block)
  end

  def my_practice?(practice)
    return false if current_user.blank?
    [:everyone, current_user.job].include?(practice.target)
  end
end
