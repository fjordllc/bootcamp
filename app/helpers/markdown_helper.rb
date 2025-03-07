# frozen_string_literal: true

module MarkdownHelper
  def markdown_to_plain_text(markdown_content)
    html = CommonMarker.render_html(markdown_content)
    Nokogiri::HTML(html).text.strip
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

  def escape_special_chars(text)
    text.gsub('&', '&amp;')
        .gsub('<', '&lt;')
        .gsub('>', '&gt;')
  end

  def process_special_case(comment, word)
    escaped_comment = escape_special_chars(comment)
    find_match_in_text(escaped_comment, word)
  end

  def process_markdown_case(comment)
    processed_comment = if comment.is_a?(String) && !comment.empty?
                          escape_special_chars(comment)
                        else
                          comment
                        end

    html_content = md2html(processed_comment)
    strip_tags(html_content).gsub(/[\r\n]/, '')
  end

  def find_match_in_text(text, word)
    return text if word.blank?

    words = word.split(/[[:space:]]+/).compact.reject(&:empty?)
    return text if words.blank?

    words_pattern = words.map { |keyword| Regexp.escape(keyword) }.join('|')
    words_regexp = Regexp.new(words_pattern, Regexp::IGNORECASE)
    match = words_regexp.match(text)
    return text if match.nil?

    begin_offset = (match.begin(0) - 50).clamp(0, Float::INFINITY)
    text[begin_offset...].strip
  end
end
