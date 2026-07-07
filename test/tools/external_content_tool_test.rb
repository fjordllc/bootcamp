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

  test 'asks Pjord to mention mentors when external links cannot be fetched' do
    stub_request(:get, 'https://example.com/unreadable')
      .to_return(status: 404, body: 'Not Found')

    result = @tool.execute(url: 'https://example.com/unreadable')

    assert_equal ExternalContent::UNREADABLE_URL_MESSAGE, result
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

  test 'returns image content for Active Storage blob redirect urls' do
    image_body = Rails.root.join('test/fixtures/files/companies-logos-1.jpg').binread
    blob_url = 'https://bootcamp.fjord.jp/rails/active_storage/blobs/redirect/signed-id/image.jpg'
    redirected_url = 'https://bootcamp.fjord.jp/rails/active_storage/disk/key/image.jpg'
    stub_request(:get, blob_url)
      .to_return(status: 302, headers: { 'Location' => redirected_url })
    stub_request(:get, redirected_url)
      .to_return(status: 200, body: image_body, headers: { 'Content-Type' => 'image/jpeg' })

    result = @tool.execute(url: blob_url)

    assert_instance_of RubyLLM::Content, result
    assert_includes result.text, '# Image'
    assert_includes result.text, "URL: #{redirected_url}"
    assert_equal 1, result.attachments.size
    assert_predicate result.attachments.first, :image?
    assert_equal image_body, result.attachments.first.content
  end

  test 'rejects non http urls' do
    assert_equal 'httpまたはhttpsのURLだけ取得できます。', @tool.execute(url: 'file:///etc/passwd')
  end

  test 'rejects private network urls' do
    result = @tool.execute(url: 'http://127.0.0.1/internal')

    assert_equal ExternalContent::UNREADABLE_URL_MESSAGE, result
  end

  test 'rejects redirects to private network urls' do
    stub_request(:get, 'https://example.com/redirect-to-private')
      .to_return(status: 302, headers: { 'Location' => 'http://127.0.0.1/internal' })

    result = @tool.execute(url: 'https://example.com/redirect-to-private')

    assert_equal ExternalContent::UNREADABLE_URL_MESSAGE, result
  end
end
