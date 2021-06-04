# frozen_string_literal: true

module ApplicationHelper
  def my_practice?(practice)
    return false if current_user.blank?

    [:everyone, current_user.job].include?(practice.target)
  end

  def md2html(text)
    html = CommonMarker.render_html(text)
    raw(html) # rubocop:disable Rails/OutputSafety
  end

  def md_summury(comment, word_count)
    summury = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    simple_format(truncate(summury, length: word_count))
  end

  def searcher_summury(comment, word_count)
    summury = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    truncate(summury, length: word_count)
  end
end
