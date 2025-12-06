# frozen_string_literal: true

require 'application_system_test_case'

module Bookmarks
  class MovieTest < ApplicationSystemTestCase
    setup do
      @movie = movies(:movie1)
      @movie.movie_data.attach(
        io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
        filename: 'movie.mp4',
        content_type: 'video/mp4'
      )
    end

    test 'bookmark movie' do
      visit_with_auth "/movies/#{@movie.id}", 'hatsuno'
      wait_for_javascript_components
      assert_selector '#bookmark-button.is-inactive', text: 'Bookmark'
      find('#bookmark-button').click
      wait_for_javascript_components
      assert_selector '#bookmark-button.is-active'
      assert_no_selector '#bookmark-button.is-inactive'
      assert_selector '#bookmark-button', text: 'Bookmark中'

      visit '/current_user/bookmarks'
      assert_text @movie.title
    end

    test 'unbookmark movie' do
      visit_with_auth "/movies/#{@movie.id}", 'kimura'
      wait_for_javascript_components
      assert_selector '#bookmark-button.is-active', text: 'Bookmark中'
      find('#bookmark-button').click
      wait_for_javascript_components
      assert_selector '#bookmark-button.is-inactive'
      assert_no_selector '#bookmark-button.is-active'
      assert_selector '#bookmark-button', text: 'Bookmark'

      visit '/current_user/bookmarks'
      assert_no_text @movie.title
    end
  end
end
