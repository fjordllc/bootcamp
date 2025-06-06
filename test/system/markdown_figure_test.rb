# frozen_string_literal: true

require 'application_system_test_case'

class MarkdownTest < ApplicationSystemTestCase
  test 'figure block test' do
    visit_with_auth new_report_path, 'komagata'
    fill_in 'report[title]', with: '画像とキャプション'
    fill_in 'report[description]', with: <<~MARKDOWN
      :::figure
      <a href="https://example.com/image.jpg"><img src="https://example.com/image.jpg"></a>
      キャプション本文
      :::
    MARKDOWN

    within '.js-preview' do
      assert_selector 'figure'
      assert_selector 'figcaption', text: 'キャプション本文'
      assert_no_selector 'p', text: ''
    end
  end
end
