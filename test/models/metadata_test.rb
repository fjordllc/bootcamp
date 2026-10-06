# frozen_string_literal: true

require 'test_helper'

class MetadataTest < ActiveSupport::TestCase
  test '#fetch falls back to YouTube oEmbed when YouTube page fetch fails' do
    url = 'https://www.youtube.com/watch?v=8LudKmk7yPM'
    stub_request(:get, url).to_return(status: 403, body: 'Forbidden')
    stub_request(:get, 'https://www.youtube.com/oembed')
      .with(query: { url:, format: 'json' })
      .to_return(
        status: 200,
        body: {
          title: '角谷トーク2023 本編',
          thumbnail_url: 'https://i.ytimg.com/vi/8LudKmk7yPM/hqdefault.jpg'
        }.to_json
      )

    metadata = fetch(url)

    assert metadata
    assert_equal '角谷トーク2023 本編', metadata[:title]
    assert_equal 'https://i.ytimg.com/vi/8LudKmk7yPM/hqdefault.jpg', metadata[:images]
    assert_equal 'YouTube', metadata[:site_name]
    assert_equal 'https://www.youtube.com', metadata[:site_url]
  end

  test '#fetch returns nil when page fetch raises network error' do
    url = 'https://example.com/'
    stub_request(:get, url).to_raise(SocketError)

    assert_nil fetch(url)
  end

  test '#fetch returns nil when YouTube oEmbed raises network error' do
    url = 'https://www.youtube.com/watch?v=8LudKmk7yPM'
    stub_request(:get, url).to_return(status: 403, body: 'Forbidden')
    stub_request(:get, 'https://www.youtube.com/oembed')
      .with(query: { url:, format: 'json' })
      .to_raise(Net::OpenTimeout)

    assert_nil fetch(url)
  end
  test '#fetch rejects unsafe endpoints before transport' do
    {
      'http://127.0.0.1/' => ['127.0.0.1'],
      'http://[::ffff:127.0.0.1]/' => ['::ffff:127.0.0.1'],
      'https://example.com/' => ['93.184.216.34', '10.0.0.1']
    }.each do |url, addresses|
      Addrinfo.stub(:getaddrinfo, addresses.map { |address| Addrinfo.ip(address) }) do
        Net::HTTP.stub(:new, ->(*) { flunk 'unsafe destination reached transport' }) do
          assert_nil Metadata.new(url).fetch
        end
      end
    end
  end

  test '#fetch rejects invalid schemes and userinfo before DNS or transport' do
    ['file:///etc/hosts', 'ftp://example.com/', 'https://user:password@example.com/', 'https://@example.com/', 'http://['].each do |url|
      Addrinfo.stub(:getaddrinfo, ->(*) { flunk 'invalid URL reached DNS' }) do
        Net::HTTP.stub(:new, ->(*) { flunk 'invalid URL reached transport' }) do
          assert_nil Metadata.new(url).fetch
        end
      end
    end
  end

  test '#fetch rejects unsafe redirects without retrying YouTube oEmbed' do
    url = 'https://www.youtube.com/watch?v=example'
    stub_request(:get, %r{https://www.youtube.com/oembed}).to_return(status: 503)
    ['http://127.0.0.1/private', 'https://user:password@example.com/private', 'file:///etc/hosts'].each do |destination|
      stub_request(:get, url).to_return(status: 302, headers: { 'Location' => destination })
      Addrinfo.stub(:getaddrinfo, lambda { |host, *|
        [Addrinfo.ip(host == '127.0.0.1' ? '127.0.0.1' : '93.184.216.34')]
      }) do
        assert_nil Metadata.new(url).fetch
      end
    end
    assert_not_requested :get, 'http://127.0.0.1/private'
    assert_not_requested :get, %r{https://www.youtube.com/oembed}
  end

  test '#fetch preserves Unicode URL and Japanese metadata through a relative redirect' do
    url = 'https://example.com/日本語'
    stub_request(:get, url).to_return(status: 302, headers: { 'Location' => '/page' })
    stub_request(:get, 'https://example.com/page').to_return(body: html, headers: { 'Content-Type' => 'text/html; charset=UTF-8' })

    metadata = fetch(url)

    assert metadata
    assert_equal '日本語の題名', metadata[:title]
    assert_equal '日本語の説明', metadata[:description]
    assert_equal url, metadata[:url]
    assert_equal 'https://example.com/favicon.ico', metadata[:favicon]
  end

  test '#fetch decodes declared non UTF8 HTML and HTML meta charset' do
    ['text/html; charset="Shift_JIS"', 'text/html'].each do |content_type|
      body = html.sub('<head>', '<head><meta charset="Shift_JIS">').encode(Encoding::Shift_JIS).b
      stub_request(:get, 'https://example.com/').to_return(body:, headers: { 'Content-Type' => content_type })

      assert_equal '日本語の題名', fetch('https://example.com/')[:title]
    end
  end

  test '#fetch handles UTF8 HTML without a charset and ignores unknown declared charsets' do
    ['text/html', 'text/html; charset=unknown-encoding'].each do |content_type|
      stub_request(:get, 'https://example.com/').to_return(body: html.b, headers: { 'Content-Type' => content_type })

      assert_equal '日本語の題名', fetch('https://example.com/')[:title]
    end
  end

  test '#fetch bounds both HTML and YouTube oEmbed requests' do
    url = 'https://www.youtube.com/watch?v=example'
    stub_request(:get, url).to_return(status: 403)
    stub_request(:get, 'https://www.youtube.com/oembed').with(query: { url:, format: 'json' })
                                                        .to_return(body: { title: '日本語の題名' }.to_json)
    original_get = ExternalContent::HttpClient.method(:get)
    requests = []
    ExternalContent::HttpClient.stub(:get, lambda { |target, **options|
      requests << target.to_s
      assert_equal 2.megabytes, options[:max_body_bytes]
      assert_equal 10, options[:request_timeout]
      original_get.call(target, **options)
    }) do
      assert_equal '日本語の題名', fetch(url)[:title]
    end
    assert_equal 2, requests.size
  end

  test '#fetch rejects oversized HTML and oEmbed without fallback after a rejected page' do
    url = 'https://www.youtube.com/watch?v=example'
    oembed = stub_request(:get, 'https://www.youtube.com/oembed').with(query: { url:, format: 'json' })
    stub_request(:get, url).to_return(body: html + (' ' * 2.megabytes))

    # Keep oversized response bodies out of assertion failure output.
    assert fetch(url).nil?, 'oversized retrieval must return nil' # rubocop:disable Minitest/AssertNil
    assert_not_requested oembed

    stub_request(:get, url).to_return(status: 403)
    oembed.to_return(body: { title: 'x' * 2.megabytes }.to_json)
    # Keep oversized response bodies out of assertion failure output.
    assert fetch(url).nil?, 'oversized retrieval must return nil' # rubocop:disable Minitest/AssertNil
  end

  test '#fetch fails closed on timeouts but does not hide programming errors' do
    stub_request(:get, 'https://example.com/').to_return(body: html)
    ExternalContent::HttpClient.stub(:get, ->(*) { raise Timeout::Error }) do
      assert_nil fetch('https://example.com/')
    end
    ExternalContent::HttpClient.stub(:get, ->(*) { raise NoMethodError, 'fictional bug' }) do
      assert_raises(NoMethodError) { fetch('https://example.com/') }
    end
  end

  private

  def fetch(url)
    Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')]) { Metadata.new(url).fetch }
  end

  def html
    <<~HTML
      <html><head>
      <meta property="og:title" content="日本語の題名">
      <meta property="og:type" content="website">
      <meta property="og:url" content="https://example.com/">
      <meta property="og:image" content="https://example.com/image.png">
      <meta property="og:description" content="日本語の説明">
      <link rel="icon" href="/favicon.ico">
      </head></html>
    HTML
  end
end
