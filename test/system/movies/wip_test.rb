# frozen_string_literal: true

require 'application_system_test_case'

module Movies
  class WipTest < ApplicationSystemTestCase
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
      movie = movies(:movie1)
      # Ensure the movie has an attached file for the test
      movie.movie_data.attach(
        io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
        filename: 'movie.mp4',
        content_type: 'video/mp4'
      )
      visit_with_auth "/movies/#{movie.id}/edit", 'kimura'
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

    test 'show a WIP movie on movie list page' do
      visit_with_auth movies_path, 'kimura'
      assert_text 'WIPのテスト'
      element = all('.thumbnail-card.a-card').find { |component| component.has_text?('WIPのテスト') }
      within element do
        assert_selector '.a-title-label.is-wip', text: 'WIP'
      end
    end
  end
end
