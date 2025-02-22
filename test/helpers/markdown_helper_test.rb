# frozen_string_literal: true

require 'test_helper'

class MarkdownHelperTest < ActionView::TestCase
  include MarkdownHelper

  def test_markdown_to_plain_text_converts_markdown_to_plain_text
    markdown = "# Hello, world! \n This is a **test**."
    expected_plain_text = "Hello, world!\nThis is a test."
    assert_equal expected_plain_text, markdown_to_plain_text(markdown)

    markdown = "<script>alert('xss');</script>"
    expected_plain_text = ''
    assert_equal expected_plain_text, markdown_to_plain_text(markdown)

    markdown = '<div>test</div>'
    expected_plain_text = ''
    assert_equal expected_plain_text, markdown_to_plain_text(markdown)
  end

  def test_markdown_to_plain_text_handles_empty_markdown
    assert_equal '', markdown_to_plain_text('')
  end
end
