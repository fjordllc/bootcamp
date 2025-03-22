# frozen_string_literal: true

require 'test_helper'

class MarkdownHelperTest < ActionView::TestCase
  include MarkdownHelper

  test 'markdown_to_plain_text_converts_markdown_to_plain_text' do
    markdown = "# Hello, world! \n This is a **test**."
    expected_plain_text = "Hello, world!\nThis is a test."
    assert_equal expected_plain_text, markdown_to_plain_text(markdown)
  end

  test 'markdown_to_plain_text_handles_empty_markdown' do
    assert_equal '', markdown_to_plain_text('')
  end
end
