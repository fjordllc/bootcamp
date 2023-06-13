# frozen_string_literal: true

module MetaTagsHelper
  # rubocop:disable Metrics/MethodLength
  def default_meta_tags
    {
      site: 'FBC',
      reverse: true,
      charset: 'utf-8',
      description: '月額29.800円、全機能が使えるお試し期間付き。フィヨルドブートキャンプは現場の即戦力になるためのスキルとプログラミングの楽しさを伝える、現役エンジニアが考える理想のプログラミングスクールの実現に励んでいます。',
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

  def welcome_meta_tags
    default_meta_tags.deep_merge({
                                   title: title,
                                   og: {
                                     title: title || 'FJORD BOOT CAMP（フィヨルドブートキャンプ）'
                                   },
                                   twitter: {
                                     title: title || 'FJORD BOOT CAMP（フィヨルドブートキャンプ）'
                                   }
                                 })
  end
end
