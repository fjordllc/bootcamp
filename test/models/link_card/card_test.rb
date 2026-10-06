# frozen_string_literal: true

require 'test_helper'

module LinkCard
  class CardTest < ActiveSupport::TestCase
    test '#metadata' do
      with_public_dns do
        VCR.use_cassette 'link_card/metadata', record: :none do
          params = { url: 'https://bootcamp.fjord.jp/faq', tweet: nil }
          card = LinkCard::Card.new(params[:url], params[:tweet])
          metadata = card.metadata

          assert_equal 'fjord bootcamp', metadata[:site_name]
          assert_equal 'https://bootcamp.fjord.jp', metadata[:site_url]
          assert_equal 'FAQ', metadata[:title]
          assert_includes metadata[:description], 'フィヨルドブートキャンプに寄せられたよくあるお問い合わせとその回答の一覧です。'
        end
      end
    end

    test '#metadata for tweet' do
      with_public_dns do
        VCR.use_cassette 'link_card/metadata/tweet', record: :none do
          params = { url: 'https://x.com/fjordbootcamp/status/1866097842483503117', tweet: '1' }
          card = LinkCard::Card.new(params[:url], params[:tweet])
          metadata = JSON.parse(card.metadata, symbolize_names: true)

          assert_equal 'フィヨルドブートキャンプ', metadata[:author_name]
          assert_equal 'https://twitter.com/fjordbootcamp', metadata[:author_url]
          assert_equal 'https://twitter.com/fjordbootcamp/status/1866097842483503117', metadata[:url]
          assert_includes metadata[:html], '<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">12/26(木)19:30から『FBC忘年会2024』を開催します！ご参加お待ちしております😃'
        end
      end
    end

    test '#metadata does not garble text for specific domains' do
      with_public_dns do
        VCR.use_cassette 'link_card/metadata/not_garble_text', record: :none do
          params = { url: 'https://www.youtube.com/watch?v=8LudKmk7yPM', tweet: nil }
          card = LinkCard::Card.new(params[:url], params[:tweet])
          metadata = card.metadata

          assert_equal 'YouTube', metadata[:site_name]
          assert_equal 'https://www.youtube.com', metadata[:site_url]
          assert_equal '角谷トーク2023 本編', metadata[:title]
          assert_includes metadata[:description], 'フィヨルドブートキャンプの顧問、角谷信太郎氏によるプログラミング学習者に向けたトークイベント'
        end
      end
    end

    test '#metadata does not cache failed fetch' do
      store = ActiveSupport::Cache::MemoryStore.new
      params = { url: 'https://www.youtube.com/watch?v=8LudKmk7yPM', tweet: nil }
      card = LinkCard::Card.new(params[:url], params[:tweet])
      metadata = { title: '角谷トーク2023 本編' }
      requests = [nil, metadata]

      Rails.stub(:cache, store) do
        card.stub(:request, -> { requests.shift }) do
          assert_nil card.metadata
          assert_equal metadata, card.metadata
        end
      end
    end

    test '#metadata does not cache a rejected DNS destination' do
      url = 'https://example.com/'
      store = ActiveSupport::Cache::MemoryStore.new
      card = Card.new(url, nil)
      html = <<~HTML
        <html><head>
        <meta property="og:title" content="Recovered">
        <meta property="og:type" content="website">
        <meta property="og:url" content="https://example.com/">
        <meta property="og:image" content="https://example.com/image.png">
        </head></html>
      HTML
      stub_request(:get, url).to_return(body: html)
      Rails.stub(:cache, store) do
        Resolv.stub(:getaddress, '93.184.216.34') do
          Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('10.0.0.1')]) do
            Net::HTTP.stub(:new, ->(*) { flunk 'unsafe destination reached transport' }) do
              assert_nil card.metadata
              assert_nil store.read(card.send(:cache_key))
            end
          end
          Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')]) do
            metadata = card.metadata
            assert metadata
            assert_equal 'Recovered', metadata[:title]
          end
        end
      end
      assert_requested :get, url, times: 1
    end

    test '#metadata encodes the entire tweet URL as one query parameter and bounds oEmbed' do
      url = 'https://x.com/example/status/123?name=日本語&other=value#fragment'
      body = { author_name: '日本語', html: '<p>本文</p>' }.to_json
      stub_request(:get, %r{https://publish.twitter.com/oembed}).to_return(status: 503)
      stub_request(:get, 'https://publish.twitter.com/oembed').with(query: { url: }).to_return(body: body.b)
      original_get = ExternalContent::HttpClient.method(:get)
      requests = 0
      ExternalContent::HttpClient.stub(:get, lambda { |target, **options|
        requests += 1
        assert_equal 2.megabytes, options[:max_body_bytes]
        assert_equal 10, options[:request_timeout]
        original_get.call(target, **options)
      }) do
        with_public_dns do
          metadata = Card.new(url, '1').metadata
          assert metadata
          assert_equal Encoding::UTF_8, metadata.encoding
          assert_equal '日本語', JSON.parse(metadata)['author_name']
        end
      end
      assert_equal 1, requests
    end

    test '#metadata does not cache rejected tweet redirects or oversized responses' do
      url = 'https://x.com/example/status/123'
      store = ActiveSupport::Cache::MemoryStore.new
      card = Card.new(url, '1')
      oembed = stub_request(:get, 'https://publish.twitter.com/oembed').with(query: { url: })
      oembed.to_return(status: 302, headers: { 'Location' => 'http://127.0.0.1/private' })
      Rails.stub(:cache, store) do
        Resolv.stub(:getaddress, '93.184.216.34') do
          Addrinfo.stub(:getaddrinfo, lambda { |host, *|
            [Addrinfo.ip(host == '127.0.0.1' ? '127.0.0.1' : '93.184.216.34')]
          }) do
            assert_nil card.metadata
            assert_nil store.read(card.send(:cache_key))
          end
          oembed.to_return(body: 'x' * (2.megabytes + 1))
          Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')]) do
            # Keep oversized response bodies out of assertion failure output.
            assert card.metadata.nil?, 'oversized retrieval must return nil' # rubocop:disable Minitest/AssertNil
          end
          assert_nil store.read(card.send(:cache_key))
          oembed.to_return(body: '{"html":"recovered"}')
          Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')]) { assert_equal '{"html":"recovered"}', card.metadata }
        end
      end
      assert_not_requested :get, 'http://127.0.0.1/private'
      assert_requested oembed, times: 3
    end

    test '#metadata fails closed on tweet timeout and invalid UTF8 without caching' do
      url = 'https://x.com/example/status/123'
      Rails.stub(:cache, ActiveSupport::Cache::MemoryStore.new) do
        with_public_dns do
          stub_request(:get, 'https://publish.twitter.com/oembed').with(query: { url: }).to_raise(Timeout::Error)
          assert_nil Card.new(url, '1').metadata
          stub_request(:get, 'https://publish.twitter.com/oembed').with(query: { url: }).to_return(body: "\xFF".b)
          assert_nil Card.new(url, '1').metadata
        end
      end
    end

    test '#metadata validates tweet URL syntax without unbounded DNS prechecks' do
      ['ftp://example.com/', 'https://user:password@example.com/', 'https://@example.com/', 'http://['].each do |url|
        Resolv.stub(:getaddress, ->(*) { flunk 'card must not perform a separate DNS lookup' }) do
          Net::HTTP.stub(:new, ->(*) { flunk 'invalid tweet URL reached transport' }) do
            assert_nil Card.new(url, '1').metadata
          end
        end
      end
      url = 'https://x.com/example/status/123'
      stub_request(:get, 'https://publish.twitter.com/oembed').with(query: { url: }).to_return(body: '{}')
      Resolv.stub(:getaddress, ->(*) { flunk 'card must not perform a separate DNS lookup' }) do
        Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')]) do
          assert_equal '{}', Card.new(url, '1').metadata
        end
      end
    end

    test '#metadata does not reuse a legacy cache entry for a blocked destination' do
      url = 'http://127.0.0.1/'
      store = ActiveSupport::Cache::MemoryStore.new
      legacy_key = ['link_card', 'metadata', url]
      store.write(legacy_key, { title: 'Legacy private response' })

      Rails.stub(:cache, store) do
        Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('127.0.0.1')]) do
          Net::HTTP.stub(:new, ->(*) { flunk 'unsafe destination reached transport' }) do
            card = Card.new(url, nil)
            assert_nil card.metadata
            assert_nil store.read(card.send(:cache_key))
          end
        end
      end
      assert_equal({ title: 'Legacy private response' }, store.read(legacy_key))
    end

    test '#metadata refetches legacy public entries once and caches the bounded result' do
      url = 'https://example.com/'
      store = ActiveSupport::Cache::MemoryStore.new
      legacy_key = ['link_card', 'metadata', url]
      store.write(legacy_key, { title: 'Legacy unbounded response' })
      html = <<~HTML
        <html><head>
        <meta property="og:title" content="Fresh bounded response">
        <meta property="og:type" content="website">
        <meta property="og:url" content="https://example.com/">
        <meta property="og:image" content="https://example.com/image.png">
        </head></html>
      HTML
      stub_request(:get, url).to_return(body: html)

      Rails.stub(:cache, store) do
        with_public_dns do
          card = Card.new(url, nil)
          metadata = card.metadata
          assert_equal 'Fresh bounded response', metadata[:title]
          assert_equal url, metadata[:url]
          assert_equal metadata, card.metadata
          assert_equal metadata, store.read(card.send(:cache_key))
        end
      end
      assert_requested :get, url, times: 1
      assert_equal({ title: 'Legacy unbounded response' }, store.read(legacy_key))
    end

    private

    def with_public_dns(&block)
      Resolv.stub(:getaddress, '93.184.216.34') do
        Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')], &block)
      end
    end
  end
end
