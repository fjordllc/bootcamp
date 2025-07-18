# frozen_string_literal: true

require 'test_helper'

class MarkdownHelperTest < ActionView::TestCase
  include MarkdownHelper

  test 'markdown to plain text converts markdown to plain text' do
    markdown = "# Hello, world! \n This is a **test**."
    expected_plain_text = "Hello, world!\nThis is a test."
    assert_equal expected_plain_text, md2plain_text(markdown)
  end

  test 'markdown to plain text handles empty markdown' do
    assert_equal '', md2plain_text('')
  end
end
