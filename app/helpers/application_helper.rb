# frozen_string_literal: true

module ApplicationHelper
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

  def searchable_summary(comment, word_count, word = nil)
    summary = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    return truncate(summary, length: word_count) if word.nil?

    characters_before_word = 50
    characters_after_word = 50
    word_index = summary.index(word)
    start_index = word_index - characters_before_word
    display_characters = characters_before_word + word.size + characters_after_word

    if start_index >= 0
      summary[start_index, display_characters]
    else
      summary[0, display_characters]
    end
  end
end
