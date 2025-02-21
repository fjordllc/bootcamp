# frozen_string_literal: true

require 'application_system_test_case'

class AlumniVoiceTest < ApplicationSystemTestCase
  test 'displays articles tagged with alumni voice' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: '最新の記事のタイトルです。'
    fill_in 'article[body]', with: '最新の記事の本文です。'
    fill_in 'article[summary]', with: '最新の記事のサマリーです。'
    tag_input = find '.tagify__input'
    tag_input.set '卒業生の声'
    tag_input.native.send_keys :enter

    click_on '公開する'

    visit_with_auth alumni_voices_path, 'komagata'

    within first '.thumbnail-card__title' do
      assert_text '最新の記事のタイトルです。'
    end
    within first '.thumbnail-card__description' do
      assert_text '最新の記事のサマリーです。'
    end
    other_article = articles(:article1)
    assert_no_text other_article.title

    first('a.thumbnail-card__inner').click
    within '.article__title' do
      assert_text '最新の記事のタイトルです。'
    end
    within '.article__body' do
      assert_text '最新の記事の本文です。'
    end
  end

  test 'articles with alumni voice tag are listed in published_at order' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: '古い記事のタイトルです。'
    fill_in 'article[body]', with: '古い記事の本文です。'
    fill_in 'article[summary]', with: '古い記事のサマリーです。'
    tag_input = find '.tagify__input'
    tag_input.set '卒業生の声'
    tag_input.native.send_keys :enter

    travel_to Time.zone.local(2024, 1, 1) do
      click_on '公開する'
    end

    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: '新しい記事のタイトルです。'
    fill_in 'article[body]', with: '新しい記事の本文です。'
    fill_in 'article[summary]', with: '新しい記事のサマリーです。'
    tag_input = find '.tagify__input'
    tag_input.set '卒業生の声'
    tag_input.native.send_keys :enter

    travel_to Time.zone.local(2024, 1, 2) do
      click_on '公開する'
    end

    visit_with_auth alumni_voices_path, 'komagata'

    within all('.thumbnail-card__title')[0] do
      assert_text '新しい記事のタイトルです。'
    end

    within all('.thumbnail-card__title')[1] do
      assert_text '古い記事のタイトルです。'
    end
  end

  test 'wip articles are not displayed' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: 'WIPの記事のタイトルです。'
    fill_in 'article[body]', with: 'WIPの記事の本文です。'
    fill_in 'article[summary]', with: 'WIPの記事のサマリーです。'
    tag_input = find '.tagify__input'
    tag_input.set '卒業生の声'
    tag_input.native.send_keys :enter

    click_on 'WIP'

    visit_with_auth alumni_voices_path, 'komagata'
    assert_no_text 'WIPの記事のタイトルです。'
  end
end
