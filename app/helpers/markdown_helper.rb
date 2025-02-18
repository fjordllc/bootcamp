# frozen_string_literal: true

module MarkdownHelper

  def markdown_to_plain_text(markdown_content)
    return "" if markdown_content.blank?

    parse_options = [:DEFAULT, :UNSAFE, :LIBERAL_HTML_TAG]
    extensions = []
    doc = CommonMarker.render_doc(markdown_content, parse_options, extensions)
    html = doc.to_html([:UNSAFE])
    nokodoc = Nokogiri::HTML(html)
    nokodoc.search('script').remove
    nokodoc.text.strip
  end
end