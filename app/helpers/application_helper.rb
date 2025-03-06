# frozen_string_literal: true

module ApplicationHelper
  EXTRACTING_CHARACTERS = 50

  def my_practice?(practice)
    return false if current_user.blank?

    [:everyone, current_user.job].include?(practice.target)
  end

  def md2html(text)
    return '' if text.nil?

    html = Kramdown::Document.new(text, input: 'GFM', hard_wrap: true).to_html
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    doc.css('img').each do |img|
      img.remove_attribute('width')
      img.remove_attribute('height')
      img['style'] = [img['style'], 'max-width: 100%;'].compact.join(' ')
    end
    raw(doc.to_html) # rubocop:disable Rails/OutputSafety
  end

  def md_summary(comment, word_count)
    summary = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    simple_format(truncate(summary, length: word_count))
  end

  def searchable_summary(comment, word = '')
    summary = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    words = word.split(/[[:space:]]+/).compact.reject(&:empty?) unless word.nil?
    return summary if words.blank?

    words_pattern = words.map { |keyword| Regexp.escape(keyword) }.join('|')
    words_regexp = Regexp.new(words_pattern, Regexp::IGNORECASE)
    match = words_regexp.match(summary)
    return summary if match.nil?

    begin_offset = (match.begin(0) - EXTRACTING_CHARACTERS).clamp(0, Float::INFINITY)
    summary[begin_offset...]
  end
end
