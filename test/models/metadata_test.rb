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

    metadata = Metadata.new(url).fetch

    assert_equal '角谷トーク2023 本編', metadata[:title]
    assert_equal 'https://i.ytimg.com/vi/8LudKmk7yPM/hqdefault.jpg', metadata[:images]
    assert_equal 'YouTube', metadata[:site_name]
    assert_equal 'https://www.youtube.com', metadata[:site_url]
  end

  test '#fetch returns nil when page fetch raises network error' do
    url = 'https://example.com/'
    stub_request(:get, url).to_raise(SocketError)

    assert_nil Metadata.new(url).fetch
  end

  test '#fetch returns nil when YouTube oEmbed raises network error' do
    url = 'https://www.youtube.com/watch?v=8LudKmk7yPM'
    stub_request(:get, url).to_return(status: 403, body: 'Forbidden')
    stub_request(:get, 'https://www.youtube.com/oembed')
      .with(query: { url:, format: 'json' })
      .to_raise(Net::OpenTimeout)

    assert_nil Metadata.new(url).fetch
  end
end
