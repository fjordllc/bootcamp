# frozen_string_literal: true

require 'application_system_test_case'

class MoviesTest < ApplicationSystemTestCase
  test 'GET /movies' do
    visit_with_auth '/movies', 'kimura'
    assert_equal '動画 | FBC', title
  end

  test 'show movie' do
    visit_with_auth "/movies/#{movies(:movie1).id}", 'kimura'
    assert_equal '動画: mp4動画 | FBC', title
  end

  test 'page has a comment form ' do
    visit_with_auth "/movies/#{movies(:movie1).id}", 'kimura'
    assert_selector '.thread-comment-form'
  end

  test 'add new mp4 movie' do
    visit_with_auth new_movie_path, 'kimura'
    assert_equal new_movie_path, current_path
    fill_in 'movie[title]', with: '新規動画を作成する'
    fill_in 'movie[description]', with: '新規動画を作成する本文です'
    attach_file 'movie[movie_data]', 'test/fixtures/files/movies/movie1.mp4'
    click_button '動画を追加する'
    assert_text '動画を追加しました'
  end

  test 'add new mov movie' do
    visit_with_auth new_movie_path, 'kimura'
    assert_equal new_movie_path, current_path
    fill_in 'movie[title]', with: '新規動画を作成する'
    fill_in 'movie[description]', with: '新規動画を作成する本文です'
    attach_file 'movie[movie_data]', 'test/fixtures/files/movies/movie2.mov'
    click_button '動画を追加する'
    assert_text '動画を追加しました'
  end

  test 'doc can relate practice' do
    visit_with_auth new_movie_path, 'kimura'
    fill_in 'movie[title]', with: '動画に関連プラクティスを指定'
    fill_in 'movie[description]', with: '動画に関連プラクティスを指定'
    first('.choices__inner').click
    find('.choices__item--choice', text: '[UNIX] Linuxのファイル操作の基礎を覚える').click
    attach_file 'movie[movie_data]', 'test/fixtures/files/movies/movie1.mp4'
    click_button '動画を追加する'
    assert_text 'Linuxのファイル操作の基礎を覚える'
  end

  test 'show comment count' do
    visit_with_auth "/movies/#{movies(:movie1).id}", 'kimura'
    assert_selector '#comment_count', text: 0

    fill_in 'new_comment[description]', with: 'コメント数表示のテストです。'
    click_button 'コメントする'

    visit current_path
    assert_selector '#comment_count', text: 1
  end
end
