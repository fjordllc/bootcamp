# frozen_string_literal: true

module MetaTagsHelper
  # rubocop:disable Metrics/MethodLength
  def default_meta_tags
    {
      site: 'FBC',
      reverse: true,
      charset: 'utf-8',
      description: '現場の即戦力になれるプログラミングスクール。',
      viewport: 'width=device-width, initial-scale=1.0',
      og: {
        title: :title,
        type: 'website',
        site_name: 'fjord bootcamp',
        description: :description,
        image: 'https://bootcamp.fjord.jp/ogp/ogp.png',
        url: 'https://bootcamp.fjord.jp'
      },
      twitter: {
        card: 'summary',
        site: '@fjordbootcamp',
        description: :description,
        image: 'https://bootcamp.fjord.jp/ogp/ogp.png',
        domain: 'https://bootcamp.fjord.jp'
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def welcome_meta_tags
    {
      title: title || nil,
      site: 'FBC',
      reverse: true,
      charset: 'utf-8',
      description: '現場の即戦力になれるプログラミングスクール。',
      viewport: 'width=device-width, initial-scale=1.0',
      og: {
        title: title || 'FJORD BOOT CAMP（フィヨルドブートキャンプ）',
        type: 'website',
        site_name: 'fjord bootcamp',
        description: :description,
        image: 'https://bootcamp.fjord.jp/ogp/ogp.png',
        url: 'https://bootcamp.fjord.jp'
      },
      twitter: {
        title: title || 'FJORD BOOT CAMP（フィヨルドブートキャンプ）',
        card: 'summary',
        site: '@fjordbootcamp',
        description: :description,
        image: 'https://bootcamp.fjord.jp/ogp/ogp.png',
        domain: 'https://bootcamp.fjord.jp'
      }
    }
  end
  # rubocop:enable Metrics/MethodLength
end
