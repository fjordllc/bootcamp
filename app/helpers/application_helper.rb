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

  def md2html(text)
    html = CommonMarker.render_html(text)
    raw(html)
  end

  def md_summury(comment, word_count)
    summury = strip_tags(md2html(comment)).gsub(/[\r\n]/, "")
    simple_format(truncate(summury, length: word_count))
  end
end
