# frozen_string_literal: true

require 'test_helper'

class RollbarPartialTest < ActionView::TestCase
  test 'does not report Chrome extension errors' do
    assert blocked?('chrome-extension://ddobgcfepfdpccmgnpfgjcomccpkcdjj/content.js')
  end

  test 'does not report errors raised inside the Hatena Bookmark button script' do
    assert blocked?('https://b.st-hatena.com/js/bookmark_button.js')
  end

  test 'reports errors raised in scripts of this application' do
    assert_not blocked?('https://bootcamp.fjord.jp/packs/js/application.js')
  end

  test 'reports errors raised on hosts that only resemble the Hatena Bookmark script host' do
    assert_not blocked?('https://bxst-hatena.com/js/bookmark_button.js')
    assert_not blocked?('https://b.st-hatena.com.example.com/js/bookmark_button.js')
    assert_not blocked?('https://example.com/?from=https://b.st-hatena.com/js/bookmark_button.js')
  end

  private

  # Rollbar.js drops an item when a stack frame's filename matches any hostBlockList entry as a regular expression.
  def blocked?(filename)
    host_block_list.any? { |pattern| Regexp.new(pattern).match?(filename) }
  end

  def host_block_list
    @host_block_list ||= begin
      render partial: 'application/rollbar'
      JSON.parse(rendered[/hostBlockList: (\[.*\]),$/, 1])
    end
  end
end
