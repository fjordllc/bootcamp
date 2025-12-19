# frozen_string_literal: true

require 'application_system_test_case'

module Movies
  class CrudTest < ApplicationSystemTestCase
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

    test 'destroy movie' do
      movie = movies(:movie6)
      # Ensure the movie has an attached file for the test
      movie.movie_data.attach(
        io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
        filename: 'movie.mp4',
        content_type: 'video/mp4'
      )
      visit_with_auth "/movies/#{movie.id}", 'komagata'

      accept_confirm do
        click_link '削除する'
      end

      assert_current_path movies_path
      assert_no_text '削除のテスト'
    end
  end
end
