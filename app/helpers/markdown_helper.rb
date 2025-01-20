# frozen_string_literal: true

module MarkdownHelper
  require 'redcarpet'
  require 'nokogiri'

  def markdown_to_plain_text(markdown_content)
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer)
    html_content = markdown.render(markdown_content)
    Nokogiri::HTML(html_content).text.strip
  end
end
