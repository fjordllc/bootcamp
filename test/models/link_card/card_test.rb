# frozen_string_literal: true

require 'test_helper'

module LinkCard
  class CardTest < ActiveSupport::TestCase
    test '#metadata' do
      VCR.use_cassette 'link_card/metadata' do
        params = { url: 'https://bootcamp.fjord.jp/faq', tweet: nil }
        card = LinkCard::Card.new(params[:url], params[:tweet])
        metadata = card.metadata

        assert_equal 'fjord bootcamp', metadata[:site_name]
        assert_equal 'https://bootcamp.fjord.jp', metadata[:site_url]
        assert_equal 'FAQ', metadata[:title]
        assert_includes metadata[:description], 'フィヨルドブートキャンプに寄せられたよくあるお問い合わせとその回答の一覧です。'
      end
    end

    test '#metadata for tweet' do
      VCR.use_cassette 'link_card/metadata/tweet' do
        params = { url: 'https://x.com/fjordbootcamp/status/1866097842483503117', tweet: '1' }
        card = LinkCard::Card.new(params[:url], params[:tweet])
        metadata = JSON.parse(card.metadata, symbolize_names: true)

        assert_equal 'フィヨルドブートキャンプ', metadata[:author_name]
        assert_equal 'https://twitter.com/fjordbootcamp', metadata[:author_url]
        assert_equal 'https://twitter.com/fjordbootcamp/status/1866097842483503117', metadata[:url]
        assert_includes metadata[:html], '<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">12/26(木)19:30から『FBC忘年会2024』を開催します！ご参加お待ちしております😃'
      end
    end

    test '#metadata does not garble text for specific domains' do
      VCR.use_cassette 'link_card/metadata/not_garble_text' do
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
end
