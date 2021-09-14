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
    return truncate(summary, length: word_count) if word.blank?

    words = word.split(/[[:space:]]/).compact.reject(&:empty?)
    word_indexes = create_indexes(summary, words)
    first_match_word_index = word_indexes.compact.min
    return truncate(summary, length: word_count) if first_match_word_index.nil?

    start_index = first_match_word_index - EXTRACTING_CHARACTERS

    first_match_word = words[word_indexes.index(first_match_word_index)]
    matched_characters_before_and_after_word(summary, first_match_word, start_index)
  end

  def create_indexes(summary, words)
    words.map do |keyword|
      summary.index(/#{keyword}/i)
    end
  end

  def matched_characters_before_and_after_word(summary, first_match_word, start_index)
    summary =~ /#{first_match_word}/i
    match_before = if start_index >= 0
                     Regexp.last_match.pre_match.slice(start_index, EXTRACTING_CHARACTERS)
                   else
                     Regexp.last_match.pre_match.slice(0, EXTRACTING_CHARACTERS)
                   end
    match_word = Regexp.last_match[0]
    match_after = Regexp.last_match.post_match.slice(0, EXTRACTING_CHARACTERS)

    match_before + match_word + match_after
  end
end
