# frozen_string_literal: true

module ApplicationHelper
  def my_practice?(practice)
    return false if current_user.blank?

    [:everyone, current_user.job].include?(practice.target)
  end

  def md2html(text)
    html = CommonMarker.render_html(text) unless text.nil?
    raw(html) # rubocop:disable Rails/OutputSafety
  end

  def md_summary(comment, word_count)
    summary = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    simple_format(truncate(summary, length: word_count))
  end

  def searchable_summary(comment, word_count)
    summary = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    truncate(summary, length: word_count)
  end
end
