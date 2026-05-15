# frozen_string_literal: true

module MetaTagsHelper
  # rubocop:disable Metrics/MethodLength
  def default_meta_tags
    {
      site: 'FBC',
      reverse: true,
      charset: 'utf-8',
      description: '月額32,780円（税込）、全機能が使えるお試し期間付き。FBCは現場の即戦力になるためのスキルとプログラミングの楽しさを伝える、現役ソフトウェアエンジニアが考える理想のプログラミングスクールの実現に励んでいます。',
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
                                   title:,
                                   description: '月額32,780円（税込）、全機能が使えるお試し期間付き。FBCは現場の即戦力になるためのスキルとプログラミングの楽しさを伝える、現役ソフトウェアエンジニアが考える理想のプログラミングスクールの実現に励んでいます。',
                                   og: {
                                     title: title || 'FJORD BOOT CAMP（フィヨルドブートキャンプ）',
                                     description: :description
                                   },
                                   twitter: {
                                     title: title || 'FJORD BOOT CAMP（フィヨルドブートキャンプ）',
                                     description: :description
                                   }
                                 })
  end
end
