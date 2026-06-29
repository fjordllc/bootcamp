# frozen_string_literal: true

require 'test_helper'

class ExternalContent::CodepenReaderTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
    @reader = ExternalContent::CodepenReader.new
  end

  test 'fetches CodePen source code from pen details endpoint' do
    stub_request(:get, 'https://codepen.io/takafumi-yamashita/pen/details/WbRjEro')
      .with(headers: { 'Accept' => 'application/json', 'User-Agent' => 'fjord-bootcamp-pjord' })
      .to_return(
        status: 200,
        body: {
          title: 'Sample Pen',
          user: 'takafumi-yamashita',
          html: '<main class="demo">Hello</main>',
          css: '.demo { color: red; }',
          js: 'console.log("hello")'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    result = @reader.fetch('https://codepen.io/takafumi-yamashita/pen/WbRjEro')

    assert_includes result, '# CodePen'
    assert_includes result, '- Title: Sample Pen'
    assert_includes result, '```html'
    assert_includes result, '<main class="demo">Hello</main>'
    assert_includes result, '```css'
    assert_includes result, '.demo { color: red; }'
    assert_includes result, '```js'
    assert_includes result, 'console.log("hello")'
  end

  test 'rejects non CodePen URLs' do
    assert_equal 'CodePenの公開Pen URLだけ取得できます。', @reader.fetch('https://example.com/pen/WbRjEro')
  end

  test 'rejects unsupported CodePen paths' do
    assert_equal 'CodePenの公開Pen URLだけ取得できます。', @reader.fetch('https://codepen.io/takafumi-yamashita/full/WbRjEro')
  end
end
