# frozen_string_literal: true

require 'test_helper'

class ExternalContent::CodepenReaderTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
    @reader = ExternalContent::CodepenReader.new
  end

  test 'fetches CodePen source code from raw URL extensions' do
    stub_request(:get, 'https://codepen.io/takafumi-yamashita/pen/WbRjEro.html')
      .with(headers: { 'Accept' => 'text/html, text/plain, */*', 'User-Agent' => 'fjord-bootcamp-pjord' })
      .to_return(status: 200, body: '<main class="demo">Hello</main>', headers: { 'Content-Type' => 'text/html' })
    stub_request(:get, 'https://codepen.io/takafumi-yamashita/pen/WbRjEro.css')
      .with(headers: { 'Accept' => 'text/css, text/plain, */*', 'User-Agent' => 'fjord-bootcamp-pjord' })
      .to_return(status: 200, body: '.demo { color: red; }', headers: { 'Content-Type' => 'text/css' })
    stub_request(:get, 'https://codepen.io/takafumi-yamashita/pen/WbRjEro.js')
      .with(headers: { 'Accept' => 'application/javascript, text/plain, */*', 'User-Agent' => 'fjord-bootcamp-pjord' })
      .to_return(status: 200, body: 'console.log("hello")', headers: { 'Content-Type' => 'application/javascript' })

    result = @reader.fetch('https://codepen.io/takafumi-yamashita/pen/WbRjEro')

    assert_includes result, '# CodePen'
    assert_includes result, '- Title: (no title)'
    assert_includes result, '- Author: (unknown)'
    assert_includes result, '```html'
    assert_includes result, '<main class="demo">Hello</main>'
    assert_includes result, '```css'
    assert_includes result, '.demo { color: red; }'
    assert_includes result, '```js'
    assert_includes result, 'console.log("hello")'
  end

  test 'falls back to pen details endpoint when raw URL extensions cannot be fetched' do
    stub_raw_source_requests(status: 403, body: 'Forbidden')
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

    assert_includes result, '- Title: Sample Pen'
    assert_includes result, '- Author: takafumi-yamashita'
    assert_includes result, '<main class="demo">Hello</main>'
    assert_includes result, '.demo { color: red; }'
    assert_includes result, 'console.log("hello")'
  end

  test 'rejects non CodePen URLs' do
    assert_equal 'CodePenの公開Pen URLだけ取得できます。', @reader.fetch('https://example.com/pen/WbRjEro')
  end

  test 'rejects unsupported CodePen paths' do
    assert_equal 'CodePenの公開Pen URLだけ取得できます。', @reader.fetch('https://codepen.io/takafumi-yamashita/full/WbRjEro')
  end

  test 'asks Pjord to mention mentors when CodePen cannot be fetched' do
    stub_raw_source_requests(status: 403, body: 'Forbidden')
    stub_request(:get, 'https://codepen.io/takafumi-yamashita/pen/details/WbRjEro')
      .to_return(status: 403, body: 'Forbidden')

    assert_equal ExternalContent::UNREADABLE_URL_MESSAGE, @reader.fetch('https://codepen.io/takafumi-yamashita/pen/WbRjEro')
  end

  private

  def stub_raw_source_requests(status:, body:)
    %w[html css js].each do |extension|
      stub_request(:get, "https://codepen.io/takafumi-yamashita/pen/WbRjEro.#{extension}")
        .to_return(status:, body:)
    end
  end
end
