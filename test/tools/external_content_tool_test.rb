# frozen_string_literal: true

require 'test_helper'

class ExternalContentToolTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
    @tool = ExternalContentTool.new
  end

  test 'reads regular web pages' do
    stub_request(:get, 'https://example.com/page')
      .to_return(
        status: 200,
        body: '<html><body><h1>Title</h1><script>ignore()</script><p>Main text</p></body></html>',
        headers: { 'Content-Type' => 'text/html' }
      )

    result = @tool.execute(url: 'https://example.com/page')

    assert_includes result, '# Web Page'
    assert_includes result, 'Title Main text'
    assert_not_includes result, 'ignore'
  end

  test 'follows redirects' do
    stub_request(:get, 'https://example.com/old')
      .to_return(status: 302, headers: { 'Location' => '/new' })
    stub_request(:get, 'https://example.com/new')
      .to_return(status: 200, body: '<html><body>Moved content</body></html>', headers: { 'Content-Type' => 'text/html' })

    result = @tool.execute(url: 'https://example.com/old')

    assert_includes result, 'URL: https://example.com/new'
    assert_includes result, 'Moved content'
  end

  test 'rejects non http urls' do
    assert_equal 'httpまたはhttpsのURLだけ取得できます。', @tool.execute(url: 'file:///etc/passwd')
  end
end
