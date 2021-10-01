# frozen_string_literal: true

module ApplicationHelper
  EXTRACTING_CHARACTERS = 50

  def my_practice?(practice)
    return false if current_user.blank?

    [:everyone, current_user.job].include?(practice.target)
  end

  def md2html(text)
    html = CommonMarker.render_html(text, :HARDBREAKS) unless text.nil?
    raw(html) # rubocop:disable Rails/OutputSafety
  end

  def md_summary(comment, word_count)
    summary = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    simple_format(truncate(summary, length: word_count))
  end

  def searchable_summary(comment, word_count, word = '')
    summary = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    words = word.split(/[[:space:]]+/).compact.reject(&:empty?) unless word.nil?
    return truncate(summary, length: word_count) if words.blank?

    words_pattern = words.map { |keyword| Regexp.escape(keyword) }.join('|')
    words_regexp = Regexp.new(words_pattern, Regexp::IGNORECASE)
    match = words_regexp.match(summary)
    return truncate(summary, length: word_count) if match.nil?

    begin_offset = (match.begin(0) - EXTRACTING_CHARACTERS).clamp(0, Float::INFINITY)
    end_offset = match.end(0) + EXTRACTING_CHARACTERS
    summary[begin_offset...end_offset]
  end
end
