# frozen_string_literal: true

require 'test_helper'

class ProductReviewCurriculumDocTest < ActiveSupport::TestCase
  setup do
    @url_options = Rails.application.routes.default_url_options.dup
    Rails.application.routes.default_url_options.merge!(host: 'bootcamp.example', protocol: 'https', port: nil)
    @page = pages(:page1)
    @page.update!(title: '架空の境界値課題', slug: 'fictional-boundaries', wip: false, body: <<~MARKDOWN)
      整数は0以上を受け付けます。

      ```ruby
      valid = value >= 0 && value < 10
      ```

      | 入力 | 結果 |
      | --- | --- |
      | 0 | 有効 |

      [追加資料](https://example.com/doc-child)
      ![図](https://example.com/doc-child.png)
    MARKDOWN
  end

  teardown do
    Rails.application.routes.default_url_options.replace(@url_options)
  end

  test 'reads only published title and raw Markdown by numeric id or valid slug on exact allowed origins' do
    ["https://bootcamp.fjord.jp/pages/#{@page.id}",
     "https://bootcamp.fjord.jp:443/pages/#{@page.slug}/?id=0#section",
     "https://bootcamp.example/pages/#{@page.id}/", "https://bootcamp.example/pages/#{@page.slug}"].each do |url|
      reader = ProductReviewCurriculumDoc.new(url)

      assert reader.support?
      evidence = reader.read
      assert_equal 'fetched', evidence[:status]
      assert_equal url, evidence[:url]
      assert_includes evidence[:content], @page.title
      assert_includes evidence[:content], @page.body
      assert_not_includes evidence[:content], '切り詰め'
    end
    assert_not_requested :get, /bootcamp/
    assert_not_requested :get, %r{example.com/doc-child}
  end

  test 'unsupported origins and paths never query pages' do
    urls = [
      "http://bootcamp.fjord.jp/pages/#{@page.id}", "https://bootcamp.fjord.jp:444/pages/#{@page.id}",
      "https://bootcamp.fjord.jp.evil.example/pages/#{@page.id}", "https://evil-bootcamp.fjord.jp/pages/#{@page.id}",
      "https://bootcamp.example:444/pages/#{@page.id}", "http://bootcamp.example/pages/#{@page.id}",
      "https://user:pass@bootcamp.fjord.jp/pages/#{@page.id}", "//bootcamp.fjord.jp/pages/#{@page.id}",
      'https://bootcamp.fjord.jp/pages/%2e%2e/products/1', 'https://bootcamp.fjord.jp/pages/../products/1',
      'https://bootcamp.fjord.jp/pages/a%2fb', 'https://bootcamp.fjord.jp/pages/Uppercase',
      'https://bootcamp.fjord.jp/pages/1.json', 'https://bootcamp.fjord.jp/pages/1/edit',
      'https://bootcamp.fjord.jp/products/1', 'https://bootcamp.fjord.jp/users/1',
      'https://bootcamp.fjord.jp/comments/1', 'https://bootcamp.fjord.jp/practices/1/submission_answer',
      'https://bootcamp.fjord.jp/pages/', "https://bootcamp.fjord.jp/pages/#{'a' * 201}", 'http://[invalid'
    ]
    Page.stub(:where, ->(*) { flunk 'unsupported URLs must not query Page' }) do
      urls.each do |url|
        reader = ProductReviewCurriculumDoc.new(url)
        assert_not reader.support?, url
        assert_nil reader.read, url
      end
    end
  end

  test 'configured origin allows only its exact scheme host and port' do
    Rails.application.routes.default_url_options.merge!(host: 'bootcamp.example', protocol: 'http', port: 3210)

    assert ProductReviewCurriculumDoc.new("http://bootcamp.example:3210/pages/#{@page.id}").support?
    assert_not ProductReviewCurriculumDoc.new("http://bootcamp.example/pages/#{@page.id}").support?
    assert_not ProductReviewCurriculumDoc.new("https://bootcamp.example:3210/pages/#{@page.id}").support?
    assert ProductReviewCurriculumDoc.new("https://bootcamp.fjord.jp/pages/#{@page.id}").support?
  end

  test 'missing and WIP docs are explicitly unavailable without HTTP fallback' do
    @page.update!(wip: true)
    [@page.id, @page.slug, 'fictional-missing-doc'].each do |identifier|
      evidence = ProductReviewCurriculumDoc.new("https://bootcamp.fjord.jp/pages/#{identifier}?wip=false").read

      assert_equal 'unavailable', evidence[:status]
      assert_includes evidence[:reason], '公開済み'
      assert_nil evidence[:content]
    end
    assert_not_requested :get, /bootcamp/
  end

  test 'caps body at twenty thousand characters and marks the remaining text unverified' do
    @page.update!(body: "#{'界' * 20_000}UNSEEN_DOC_TAIL")

    evidence = ProductReviewCurriculumDoc.new("https://bootcamp.fjord.jp/pages/#{@page.id}").read

    assert_includes evidence[:content], '界' * 20_000
    assert_not_includes evidence[:content], 'UNSEEN_DOC_TAIL'
    assert_includes evidence[:content], '切り詰め'
    assert_includes evidence[:content], '20000'
    assert_includes evidence[:content], '未確認'
  end
end
