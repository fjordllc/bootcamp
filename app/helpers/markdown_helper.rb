# frozen_string_literal: true

require 'redcarpet'
require 'nokogiri'

module MarkdownHelper
  def markdown_to_plain_text(markdown_content)
    return '' if markdown_content.blank?
    renderer = Redcarpet::Render::HTML.new(escape_html: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, strikethrough: true, fenced_code_blocks: true, no_intra_emphasis: true, space_after_headers: true)
    html_content = markdown.render(markdown_content.to_s)
    Nokogiri::HTML::DocumentFragment.parse(html_content).text.strip
  end
end
