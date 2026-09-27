# frozen_string_literal: true

module MarkdownHelper
  include ActionView::Helpers::OutputSafetyHelper

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
    summary = ActionView::Base.full_sanitizer.sanitize(md2html(comment)).gsub(/[\r\n]/, '')
    simple_format(truncate(summary, length: word_count))
  end

  def escape_special_chars(text)
    text.gsub('&', '&amp;')
        .gsub('<', '&lt;')
        .gsub('>', '&gt;')
  end

  def process_markdown_case(comment)
    processed_comment = if comment.is_a?(String) && !comment.empty?
                          escape_special_chars(comment)
                        else
                          comment
                        end

    html_content = md2html(processed_comment)
    ActionView::Base.full_sanitizer.sanitize(html_content).gsub(/[\r\n]/, '')
  end

  def md2plain_text(markdown_content)
    return '' if markdown_content.blank?

    html_content = md2html(markdown_content)
    ActionView::Base.full_sanitizer.sanitize(html_content).strip
  end
end
