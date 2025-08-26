# frozen_string_literal: true

module MetaTagsHelper
  def page_canonical_url
    send("canonical_url_for_#{controller_name}", action_name) || request.original_url
  rescue NoMethodError
    request.original_url
  end

  private

  def canonical_url_for_articles(action_name)
    case action_name
    when 'show' then article_url(controller.instance_variable_get(:@article)) if controller.instance_variable_get(:@article)
    when 'index' then articles_url
    end
  end

  def canonical_url_for_welcome(action_name)
    case action_name
    when 'index' then root_url
    when 'job_support' then job_support_url
    when 'team_development' then "#{root_url}team_development"
    when 'pricing' then "#{root_url}pricing"
    when 'practices' then "#{root_url}practices"
    when 'faq' then "#{root_url}faq"
    end
  end

  def canonical_url_for_pages(action_name)
    page = controller.instance_variable_get(:@page)
    page_url(page) if action_name == 'show' && page
  end

  def canonical_url_for_users(action_name)
    user = controller.instance_variable_get(:@user)
    user_url(user) if action_name == 'show' && user
  end

  # rubocop:disable Metrics/MethodLength
  def default_meta_tags
    {
      site: 'FBC',
      reverse: true,
      charset: 'utf-8',
      canonical: page_canonical_url,
      description: '月額29,800円、全機能が使えるお試し期間付き。FBCは現場の即戦力になるためのスキルとプログラミングの楽しさを伝える、現役ソフトウェアエンジニアが考える理想のプログラミングスクールの実現に励んでいます。',
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
                                   description: '月額29,800円、全機能が使えるお試し期間付き。FBCは現場の即戦力になるためのスキルとプログラミングの楽しさを伝える、現役ソフトウェアエンジニアが考える理想のプログラミングスクールの実現に励んでいます。',
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
