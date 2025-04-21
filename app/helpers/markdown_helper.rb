# frozen_string_literal: true

require 'redcarpet'
require 'nokogiri'

module MarkdownHelper

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

  def markdown_to_plain_text(markdown_content)
    return '' if markdown_content.blank?

    renderer = Redcarpet::Render::HTML.new(escape_html: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, strikethrough: true, fenced_code_blocks: true, no_intra_emphasis: true,
                                                 space_after_headers: true)
    html_content = markdown.render(markdown_content.to_s)
    Nokogiri::HTML::DocumentFragment.parse(html_content).text.strip
  end
end
