# frozen_string_literal: true

require 'test_helper'

class ExternalContent::CodepenReaderTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
    @reader = ExternalContent::CodepenReader.new
  end

  test 'asks Pjord to mention mentors without fetching CodePen' do
    result = @reader.fetch('https://codepen.io/takafumi-yamashita/pen/WbRjEro')

    assert_equal ExternalContent::UNREADABLE_URL_MESSAGE, result
    assert_not_requested :get, %r{\Ahttps://codepen\.io/}
  end

  test 'rejects non CodePen URLs' do
    assert_equal 'CodePenの公開Pen URLだけ取得できます。', @reader.fetch('https://example.com/pen/WbRjEro')
  end

  test 'rejects unsupported CodePen paths' do
    assert_equal 'CodePenの公開Pen URLだけ取得できます。', @reader.fetch('https://codepen.io/takafumi-yamashita/full/WbRjEro')
  end
end
