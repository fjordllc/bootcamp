# frozen_string_literal: true

module MarkdownHelper
  def markdown_to_plain_text(markdown_content)
    html = CommonMarker.render_html(markdown_content)
    Nokogiri::HTML(html).text.strip
  end
end
