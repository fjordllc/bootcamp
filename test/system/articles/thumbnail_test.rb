# frozen_string_literal: true

require 'application_system_test_case'

class Articles::ThumbnailTest < ApplicationSystemTestCase
  setup do
    @article = articles(:article1)
    @article3 = articles(:article3)
  end

  test 'if there is no featured image, the default image is set as the OGP image' do
    visit_with_auth "/articles/#{@article3.id}", 'komagata'
    verify_default_ogp_image_used
  end

  test 'can set it as an OGP image by uploading an eye-catching image' do
    visit_with_auth edit_article_path(@article), 'komagata'
    find('label[for=article_thumbnail_type_prepared_thumbnail]').click
    attach_file 'article[thumbnail]', 'test/fixtures/files/articles/ogp_images/test.jpg', make_visible: true
    click_button '更新する'

    visit "/articles/#{@article.id}"
    meta = find('meta[name="twitter:image"]', visible: false)
    content = meta.native['content']
    assert_match(/test\.jpg$/, content)
  end

  test 'can set up prepared images for eye-catching image, the prepared image is used as OGP image' do
    visit_with_auth edit_article_path(@article), 'komagata'
    find('label[for=article_thumbnail_type_ruby_on_rails]').click
    check 'サムネイル画像を本文に表示', allow_label_click: true
    click_button '更新する'

    visit "/articles/#{@article.id}"
    meta = find('meta[name="twitter:image"]', visible: false)
    content = meta.native['content']
    assert_match(/ruby_on_rails\.png$/, content)
  end

  test 'uncheck checkbox whether to display thumbnail in body' do
    visit_with_auth edit_article_path(@article), 'komagata'
    find('label[for=article_thumbnail_type_ruby_on_rails]').click
    uncheck 'サムネイル画像を本文に表示', allow_label_click: true
    click_button '更新する'

    visit "/articles/#{@article.id}"
    assert_no_selector 'img[class=article__image]'
  end
end
