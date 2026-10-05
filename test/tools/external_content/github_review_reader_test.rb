# frozen_string_literal: true

require 'test_helper'

class ExternalContent::GithubReviewReaderTest < ActiveSupport::TestCase
  DIFF = <<~DIFF
    diff --git a/example.rb b/example.rb
    index 1234567..abcdef0 100644
    --- a/example.rb
    +++ b/example.rb
    @@ -1 +1,2 @@
    -old
    +puts 1 < 2
    +puts '<strong>example</strong>'
  DIFF

  test 'fetches canonical public diff once without authentication or cache and preserves code' do
    urls = %w[https://github.com/example/repo/pull/7 https://github.com/example/repo/pull/7/files/?view=split https://github.com/example/repo/pull/7.diff]
    urls.each do |url|
      stub_request(:get, 'https://github.com/example/repo/pull/7.diff').with do |request|
        assert_nil request.headers['Authorization']
        assert_nil request.headers['Cookie']
        true
      end.to_return(body: DIFF)
      Rails.cache.stub(:read, ->(*) { flunk 'bounded review retrieval must not read cache' }) do
        result = fetch(url)
        assert_includes result, "# GitHub Review Source\n"
        assert_includes result, "- Source URL: #{url}"
        assert_includes result, '- Download URL: https://github.com/example/repo/pull/7.diff'
        assert_includes result, DIFF
        assert_includes result, '未変更ファイル'
        assert_includes result, 'バイナリ'
      end
    end
    assert_requested :get, 'https://github.com/example/repo/pull/7.diff', times: 3
  end

  test 'preserves blob and raw source bytes including markup and invalid UTF8' do
    raw = 'https://raw.githubusercontent.com/example/repo/main/example.html'
    body = "  <p>example</p>\n\t1 < 2\n".b + "\xff".b
    stub_request(:get, raw).to_return(body: body)
    [raw, 'https://github.com/example/repo/blob/main/example.html?plain=1'].each do |url|
      result = fetch(url)
      assert_includes result, body.force_encoding(Encoding::UTF_8).scrub
      assert_includes result, "- Source URL: #{url}"
      assert_includes result, "- Download URL: #{raw}"
    end
  end

  test 'does not label binary blobs or recognizable nontext formats as source code' do
    url = 'https://raw.githubusercontent.com/example/repo/main/archive.bin'
    ["binary\x00payload".b, "%PDF-1.4\n1 0 obj\n<< /Type /Catalog >>\n%%EOF\n".b,
     "PK\x03\x04zip payload".b].each do |body|
      stub_request(:get, url).to_return(body: body, headers: { 'Content-Type' => 'application/octet-stream' })
      assert_equal ExternalContent::UNREADABLE_URL_MESSAGE, fetch(url)
    end
  end

  test 'annotates truncation at fifty thousand characters' do
    stub_request(:get, 'https://raw.githubusercontent.com/example/repo/main/example.rb').to_return(body: 'あ' * 50_001)
    result = fetch('https://raw.githubusercontent.com/example/repo/main/example.rb')
    assert_includes result, 'あ' * 50_000
    assert_not_includes result, 'あ' * 50_001
    assert_includes result, '先頭50000文字'
    assert_includes result, '切り詰め'
  end

  test 'rejects successful HTML and non diff bodies for pull requests' do
    ['<html><body>Sign in</body></html>', 'not a diff', "diff --git a/a b/a\nlogin error"].each do |body|
      stub_request(:get, 'https://github.com/example/repo/pull/7.diff').to_return(body: body)
      assert_equal ExternalContent::UNREADABLE_URL_MESSAGE, fetch('https://github.com/example/repo/pull/7')
    end
  end

  test 'raw image remains an attachment' do
    image = Rails.root.join('test/fixtures/files/companies-logos-1.jpg').binread
    url = 'https://raw.githubusercontent.com/example/repo/main/example.jpg'
    stub_request(:get, url).to_return(body: image, headers: { 'Content-Type' => 'image/jpeg' })
    result = fetch(url)
    assert_kind_of Array, result
    assert_equal image, result.last.content
  end

  test 'only exact HTTPS GitHub code routes are recognized' do
    urls = %w[
      http://github.com/example/repo/pull/7
      https://github.com.evil.example/example/repo/pull/7
      https://github.com/example/repo/tree/main
      https://github.com/example/repo/issues/7
      https://github.com/example/repo
      https://user:pass@github.com/example/repo/pull/7
      https://github.com:8443/example/repo/pull/7
    ]
    urls.each do |url|
      assert_not ExternalContent::GithubReviewReader.support?(URI.parse(url)), url
    end
  end

  test 'bounded failures and private redirects do not log or become success' do
    url = 'https://github.com/example/repo/pull/7?secret=fictional'
    Rails.logger.stub(:warn, ->(*) { flunk 'must not log source or errors' }) do
      stub_request(:get, 'https://github.com/example/repo/pull/7.diff')
        .to_return(status: 302, headers: { 'Location' => 'https://user:pass@example.com/private' })
      assert_equal ExternalContent::UNREADABLE_URL_MESSAGE, fetch(url)
      stub_request(:get, 'https://github.com/example/repo/pull/7.diff').to_return(body: 'x' * (10.megabytes + 1))
      assert_equal ExternalContent::UNREADABLE_URL_MESSAGE, fetch(url)
    end
    assert_not_requested :get, 'https://example.com/private'
  end

  test 'uses bounded unauthenticated HTTP options by default' do
    response = ExternalContent::HttpClient::Response.new(url: 'https://github.com/example/repo/pull/7.diff', code: '200', body: DIFF)
    ExternalContent::HttpClient.stub(:get, lambda { |url, headers:, max_body_bytes:, request_timeout:|
      assert_equal 'https://github.com/example/repo/pull/7.diff', url
      assert_equal 10.megabytes, max_body_bytes
      assert_equal 15, request_timeout
      assert_equal({ 'User-Agent' => 'fjord-bootcamp-pjord' }, headers)
      response
    }) do
      assert_includes fetch('https://github.com/example/repo/pull/7'), DIFF
    end
  end

  test 'binary only and rename only diffs retain metadata with explicit scope' do
    ["diff --git a/a.png b/a.png\nBinary files a/a.png and b/a.png differ\n",
     "diff --git a/old.rb b/new.rb\nsimilarity index 100%\nrename from old.rb\nrename to new.rb\n"].each do |body|
      stub_request(:get, 'https://github.com/example/repo/pull/7.diff').to_return(body: body)
      result = fetch('https://github.com/example/repo/pull/7')
      assert_includes result, body
      assert_includes result, 'バイナリの内容は確認できません'
    end
  end

  private

  def fetch(url)
    Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')]) { ExternalContent::GithubReviewReader.fetch(url) }
  end
end
