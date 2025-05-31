# frozen_string_literal: true

require 'application_system_test_case'

class MoviesTest < ApplicationSystemTestCase
  test 'GET /movies' do
    visit_with_auth '/movies', 'kimura'
    assert_equal '動画 | FBC', title
  end

  test 'show the movie page' do
    visit_with_auth "/movies/#{movies(:movie1).id}", 'kimura'
    assert_equal '動画: mp4動画 | FBC', title
  end

  test 'movie has a comment form ' do
    visit_with_auth "/movies/#{movies(:movie1).id}", 'kimura'
    assert_selector '.thread-comment-form'
  end

  test 'add new mp4 movie' do
    visit_with_auth new_movie_path, 'kimura'
    assert_equal new_movie_path, current_path
    fill_in 'movie[title]', with: '新規動画を作成する'
    fill_in 'movie[description]', with: '新規動画を作成する本文です'
    attach_file 'movie[movie_data]', 'test/fixtures/files/movies/movie.mp4', make_visible: true
    click_button '動画を追加'
    assert_text '動画を追加しました'
    video = find('video')
    assert_match(/movie\.mp4$/, video.native['src'])
  end

  test 'add new mov movie' do
    visit_with_auth new_movie_path, 'kimura'
    assert_equal new_movie_path, current_path
    fill_in 'movie[title]', with: '新規動画を作成する'
    fill_in 'movie[description]', with: '新規動画を作成する本文です'
    attach_file 'movie[movie_data]', 'test/fixtures/files/movies/movie.mov', make_visible: true
    click_button '動画を追加'
    assert_text '動画を追加しました'
    video = find('video')
    assert_match(/movie\.mov$/, video.native['src'])
  end

  test 'doc can relate practice' do
    visit_with_auth new_movie_path, 'kimura'
    fill_in 'movie[title]', with: '動画に関連プラクティスを指定'
    fill_in 'movie[description]', with: '動画に関連プラクティスを指定'
    first('.choices__inner').click
    find('.choices__item--choice', text: '[UNIX] Linuxのファイル操作の基礎を覚える').click
    attach_file 'movie[movie_data]', 'test/fixtures/files/movies/movie.mp4', make_visible: true
    click_button '動画を追加'
    assert_text 'Linuxのファイル操作の基礎を覚える'
  end

  test 'show comment count' do
    movie = movies(:movie1)
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
      filename: 'movie.mp4',
      content_type: 'video/mp4'
    )
    visit_with_auth "/movies/#{movies(:movie1).id}", 'kimura'
    assert_selector '#comment_count', text: 0

    fill_in 'new_comment[description]', with: 'コメント数表示のテストです。'
    click_button 'コメントする'

    visit_with_auth "/movies/#{movies(:movie1).id}", 'kimura'
    assert_selector '#comment_count', text: 1
  end

  test 'show the edit movie page' do
    visit_with_auth "/movies/#{movies(:movie2).id}/edit", 'kimura'
    assert_equal '動画編集 | FBC', title
  end

  test 'create movie as WIP' do
    visit_with_auth new_movie_path, 'kimura'
    within('.form') do
      fill_in('movie[title]', with: 'test')
      fill_in('movie[description]', with: 'test')
    end
    attach_file 'movie_movie_data', 'test/fixtures/files/movies/movie.mp4', make_visible: true
    click_button 'WIP'
    assert_text '動画をWIPとして保存しました。'
    assert_text '動画編集'
    video = find('video')
    assert_match(/movie\.mp4$/, video.native['src'])
  end

  test 'update movie as WIP' do
    visit_with_auth "/movies/#{movies(:movie1).id}/edit", 'kimura'
    within('.form') do
      fill_in('movie[title]', with: 'test')
      fill_in('movie[description]', with: 'test')
    end
    attach_file 'movie_movie_data', 'test/fixtures/files/movies/movie.mov', make_visible: true
    click_button 'WIP'
    assert_text '動画をWIPとして保存しました。'
    assert_text '動画編集'
    video = find('video')
    assert_match(/movie\.mov$/, video.native['src'])
  end

  test 'destroy movie' do
    visit_with_auth "/movies/#{movies(:movie1).id}", 'komagata'

    accept_confirm do
      click_link '削除する'
    end

    assert_text '動画を削除しました。'
    assert_current_path movies_path
    assert_no_text 'mp4動画'
  end

  test 'show a WIP movie on movie list page' do
    visit_with_auth movies_path, 'kimura'
    assert_text 'WIPのテスト'
    element = all('.thumbnail-card.a-card').find { |component| component.has_text?('WIPのテスト') }
    within element do
      assert_selector '.a-title-label.is-wip', text: 'WIP'
    end
  end

  test 'show ghost icon and ghost text when the movie-author was deleted' do
    visit_with_auth "/movies/#{movies(:movie4).id}", 'komagata'
    within '.a-meta.is-creator' do
      assert_text 'ghost'
      img = find('img')
      assert_match(/ghost-\w+\.png$/, img.native['src'])
    end
  end
end
