# frozen_string_literal: true

module TextbookHelper
  include MarkdownHelper

  def textbook_section_body(section)
    html = md2html(section.body)
    html = add_block_indexes(html)
    html = wrap_key_terms(html, section)
    raw(html) # rubocop:disable Rails/OutputSafety
  end

  def add_block_indexes(html)
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    block_tags = %w[p pre h1 h2 h3 h4 h5 h6 ul ol blockquote table]
    index = 0

    doc.children.each do |node|
      next unless node.element? && block_tags.include?(node.name)

      node['data-block-index'] = index.to_s
      index += 1
    end

    doc.to_html
  end

  def wrap_key_terms(html, section)
    terms = section.key_terms
    return html if terms.blank?

    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    apply_term_highlighting(doc, terms, section.id)
    doc.to_html
  end

  private

  def apply_term_highlighting(doc, terms, section_id)
    terms.sort_by(&:length).reverse_each do |term|
      next if term.blank?

      pattern = Regexp.new(Regexp.escape(term), Regexp::IGNORECASE)
      highlight_term_in_doc(doc, pattern, section_id)
    end
  end

  def highlight_term_in_doc(doc, pattern, section_id)
    doc.css('p, li, td, th, dd, dt').each do |node|
      process_text_nodes(node, pattern, section_id)
    end
  end

  def process_text_nodes(node, pattern, section_id)
    node.xpath('.//text()').each do |child|
      next unless child.text?

      replaced = replace_with_tooltip(child.text, pattern, section_id)
      next if replaced == child.text

      child.replace(Nokogiri::HTML::DocumentFragment.parse(replaced))
    end
  end

  def replace_with_tooltip(text, pattern, section_id)
    text.gsub(pattern) do |match|
      build_tooltip_span(match, section_id)
    end
  end

  def build_tooltip_span(match, section_id)
    '<span class="term-keyword" data-controller="term-tooltip" ' \
      "data-term-tooltip-term-value=\"#{ERB::Util.html_escape(match)}\" " \
      "data-term-tooltip-section-id-value=\"#{section_id}\" " \
      "data-action=\"click->term-tooltip#toggle\">#{ERB::Util.html_escape(match)}</span>"
  end
end
