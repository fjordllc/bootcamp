# frozen_string_literal: true

require 'test_helper'

class MarkdownHelperTest < ActionView::TestCase
  include MarkdownHelper

  test 'markdown HTML removes executable content and unsafe URLs' do
    html = md2html(<<~MARKDOWN)
      <p onclick="alert(1)">safe text</p>
      <img src="/favicon.ico" onerror="alert(1)">
      <a href="javascript:alert(1)">unsafe link</a>
      <a href="data:text/html,unsafe">data link</a>
      <script>alert(1)</script>
      <svg onload="alert(1)"><circle /></svg>
      <math><mi>unsafe math</mi></math>
      <iframe src="https://example.com/" srcdoc="unsafe"></iframe>
      <form><input name="unsafe"></form>
      <style>body { display: none; }</style>
    MARKDOWN
    doc = Nokogiri::HTML::DocumentFragment.parse(html)

    assert_empty doc.css('script, svg, math, iframe, form, input, style, [onclick], [onerror], [srcdoc]')
    assert_empty doc.css('a[href^="javascript:"], a[href^="data:"]')
    assert_includes doc.text, 'safe text'
    assert_includes doc.text, 'unsafe link'
    assert_predicate html, :html_safe?
  end

  test 'markdown HTML preserves email formatting and sanitizes image CSS' do
    html = md2html(<<~MARKDOWN)
      # Heading

      **bold** and *emphasis* and [link](https://example.com/)

      - first
      - second

      > quotation

      ```ruby
      puts 'code'
      ```

      | column |
      | ------ |
      | value  |

      <p style="color: red; position: fixed;">colored</p>
      <img src="https://example.com/image.png" alt="image" width="800" height="600" style="position: fixed;" onerror="alert(1)">
    MARKDOWN
    doc = Nokogiri::HTML::DocumentFragment.parse(html)

    %w[h1 strong em a ul li blockquote pre code table th td].each { |tag| assert doc.at_css(tag), tag }
    assert_equal 'https://example.com/', doc.at_css('a')['href']
    assert_includes doc.at_css('p[style]')['style'], 'color'
    assert_not_includes html, 'position'
    image = doc.at_css('img')
    assert_equal 'https://example.com/image.png', image['src']
    assert_equal 'image', image['alt']
    assert_match(/max-width:\s*100%/, image['style'])
    assert_nil image['width']
    assert_nil image['height']
    assert_nil image['onerror']
  end

  test 'markdown to plain text converts markdown to plain text' do
    markdown = "# Hello, world! \n This is a **test**."
    expected_plain_text = "Hello, world!\nThis is a test."
    assert_equal expected_plain_text, md2plain_text(markdown)
  end

  test 'markdown to plain text handles empty markdown' do
    assert_equal '', md2plain_text('')
  end
end
