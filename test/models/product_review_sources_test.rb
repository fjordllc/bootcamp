# frozen_string_literal: true

require 'test_helper'

class ProductReviewSourcesTest < ActiveSupport::TestCase
  setup do
    @url_options = Rails.application.routes.default_url_options.dup
    Rails.application.routes.default_url_options.merge!(host: 'bootcamp.example', protocol: 'https')
    @addresses = [Addrinfo.ip('93.184.216.34')]
    Rails.cache.clear
  end

  teardown do
    Rails.application.routes.default_url_options.replace(@url_options)
  end

  test 'extracts rendered GFM links and images in order once without crawling' do
    stub_request(:get, 'https://example.com/page').to_return(body: '<p>Source text</p><a href="https://example.com/child">child</a><img src="https://example.com/child.png">')
    stub_request(:get, 'https://github.com/example/repo').to_return(body: '<p>Public repository</p>')
    stub_request(:get, 'https://bootcamp.example/rails/active_storage/blobs/redirect/id/image')
      .to_return(status: 302, headers: { 'Location' => 'https://example.com/image-data' })
    image = Rails.root.join('test/fixtures/files/companies-logos-1.jpg').binread
    stub_request(:get, 'https://example.com/image-data').to_return(body: image, headers: { 'Content-Type' => 'image/jpeg' })
    body = <<~MARKDOWN
      https://example.com/page
      [reference][repo]
      ![screen](/rails/active_storage/blobs/redirect/id/image)
      [duplicate](https://example.com/page#section)
      <img src="/rails/active_storage/blobs/redirect/id/image">

      [repo]: https://github.com/example/repo
    MARKDOWN

    sources = collect(body)

    assert_equal ['https://example.com/page', 'https://github.com/example/repo', 'https://bootcamp.example/rails/active_storage/blobs/redirect/id/image'],
                 sources.evidence.pluck(:url)
    assert_equal %w[fetched fetched image_attached], sources.evidence.pluck(:status)
    assert_includes sources.evidence.first[:content], 'Source text'
    assert_equal image, sources.attachments.first.content
    assert_equal 1, sources.evidence.last[:attachment_number]
    assert_requested :get, 'https://example.com/page', times: 1
    assert_requested :get, 'https://example.com/image-data', times: 1
    assert_not_requested :get, 'https://example.com/child'
    assert_not_requested :get, 'https://example.com/child.png'
  end

  test 'keeps usable sources and explicit uncertainty for failures and unsupported images' do
    stub_request(:get, 'https://example.com/missing').to_return(status: 403)
    stub_request(:get, 'https://example.com/vector').to_return(body: '<svg xmlns="http://www.w3.org/2000/svg"/>',
                                                               headers: { 'Content-Type' => 'image/svg+xml' })
    stub_request(:get, 'https://example.com/good').to_return(body: '<p>Useful</p>')

    sources = collect("https://example.com/missing\nhttps://example.com/vector\nhttps://example.com/good")

    assert_equal %w[unavailable unavailable fetched], sources.evidence.pluck(:status)
    assert_empty sources.attachments
    assert_includes sources.evidence[1][:reason], '画像形式'
    assert_includes sources.evidence.first[:reason], '未確認'
    assert_not_includes sources.evidence.to_json, '取得できなかったことには言及しない'
  end

  test 'rejects unsafe and invalid URLs without requests' do
    sources = collect('<a href="file:///etc/passwd">file</a><a href="https://user:pass@example.com/private">credentials</a><a href="http://[invalid">invalid</a>')

    assert_equal %w[unavailable unavailable unavailable], sources.evidence.pluck(:status)
    assert_empty sources.attachments
    assert_not_requested :get, /example.com/
    assert_not_includes sources.evidence.to_json, 'user:pass'
  end

  test 'invalid redirect destinations are unavailable rather than fetched error messages' do
    ['https://user:pass@example.com/private', 'file:///etc/passwd'].each do |destination|
      stub_request(:get, 'https://example.com/redirect').to_return(status: 302, headers: { 'Location' => destination })

      sources = collect('https://example.com/redirect')

      assert_equal 'unavailable', sources.evidence.first[:status]
      assert_includes sources.evidence.first[:reason], '未確認'
    end
  end

  test 'limits retrieval to ten distinct sources and records skipped URLs' do
    urls = (1..12).map { |number| "https://example.com/page#{number}" }
    urls.first(10).each { |url| stub_request(:get, url).to_return(body: '<p>Page</p>') }

    sources = collect(urls.join("\n"))

    assert_equal(10, sources.evidence.count { |item| item[:status] == 'fetched' })
    assert_equal %w[unavailable unavailable], sources.evidence.last(2).pluck(:status)
    assert_includes sources.evidence.last[:reason], '10件'
    assert_not_requested :get, urls.last
  end

  test 'oversized images are unavailable and do not prevent remaining sources' do
    stub_request(:get, 'https://example.com/large').to_return(body: 'x' * (10.megabytes + 1), headers: { 'Content-Type' => 'image/png' })
    stub_request(:get, 'https://example.com/small').to_return(body: '<p>Still usable</p>')

    sources = collect("https://example.com/large\nhttps://example.com/small")

    assert_equal %w[unavailable fetched], sources.evidence.pluck(:status)
    assert_empty sources.attachments
  end

  test 'keeps encoded image requests within per-image and aggregate provider limits' do
    image = Rails.root.join('test/fixtures/files/companies-logos-1.jpg').binread
    urls = (1..4).map { |number| "https://example.com/image#{number}" }
    urls.each_with_index do |url, index|
      size = index.zero? ? 8.megabytes : 7.megabytes
      stub_request(:get, url).to_return(body: image.ljust(size, "\0"), headers: { 'Content-Type' => 'image/jpeg' })
    end

    sources = collect(urls.join("\n"))

    assert_equal %w[unavailable image_attached image_attached unavailable], sources.evidence.pluck(:status)
    assert_includes sources.evidence.first[:reason], '7MB'
    assert_includes sources.evidence.last[:reason], '20MB'
    assert_equal 2, sources.attachments.size
  end

  test 'images exceeding provider dimensions are unavailable' do
    image = Vips::Image.black(8001, 1).write_to_buffer('.png')
    stub_request(:get, 'https://example.com/wide-image').to_return(body: image, headers: { 'Content-Type' => 'image/png' })

    sources = collect('https://example.com/wide-image')

    assert_equal 'unavailable', sources.evidence.first[:status]
    assert_includes sources.evidence.first[:reason], '8000px'
    assert_empty sources.attachments
  end

  test 'malformed image bytes are unavailable instead of reaching the provider' do
    stub_request(:get, 'https://example.com/broken-image').to_return(body: 'not an image', headers: { 'Content-Type' => 'image/png' })

    sources = collect('https://example.com/broken-image')

    assert_equal 'unavailable', sources.evidence.first[:status]
    assert_empty sources.attachments
  end

  test 'empty and no-link submissions have no evidence or attachments' do
    [nil, '', '普通の提出本文', '`https://example.com/code`'].each do |body|
      sources = collect(body)
      assert_empty sources.evidence
      assert_empty sources.attachments
    end
  end

  test 'fetch errors do not log submitted query strings or exception bodies' do
    url = 'https://example.com/failure?secret=fictional'
    stub_request(:get, url).to_raise(StandardError.new('private response body'))
    Rails.logger.stub(:warn, ->(*) { flunk 'review retrieval must not log URLs or provider bodies' }) do
      assert_equal 'unavailable', collect(url).evidence.first[:status]
    end
  end

  private

  def collect(body)
    Addrinfo.stub(:getaddrinfo, @addresses) { ProductReviewSources.new(body).collect }
  end
end
