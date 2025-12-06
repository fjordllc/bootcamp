# frozen_string_literal: true

require 'application_system_test_case'

class MoviesTest < ApplicationSystemTestCase
  test 'GET /movies' do
    visit_with_auth '/movies', 'kimura'
    assert_equal '動画 | FBC', title
  end

  test 'show the movie page' do
    movie = movies(:movie1)
    # Ensure the movie has an attached file for the test
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
      filename: 'movie.mp4',
      content_type: 'video/mp4'
    )
    visit_with_auth "/movies/#{movie.id}", 'kimura'
    assert_equal '動画: mp4動画 | FBC', title
  end

  test 'movie has a comment form ' do
    movie = movies(:movie1)
    # Ensure the movie has an attached file for the test
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
      filename: 'movie.mp4',
      content_type: 'video/mp4'
    )
    visit_with_auth "/movies/#{movie.id}", 'kimura'
    wait_for_comment_form
    assert_selector '.thread-comment-form'
  end

  test 'show comment count' do
    movie = movies(:movie1)
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
      filename: 'movie.mp4',
      content_type: 'video/mp4'
    )
    visit_with_auth "/movies/#{movie.id}", 'kimura'
    assert_selector '#comment_count', text: 0

    wait_for_comment_form
    post_comment('コメント数表示のテストです。')

    visit_with_auth "/movies/#{movie.id}", 'kimura'
    wait_for_javascript_components
    assert_selector '#comment_count', text: 1
  end

  test 'show the edit movie page' do
    movie = movies(:movie2)
    # Ensure the movie has an attached file for the test
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mov')),
      filename: 'movie.mov',
      content_type: 'video/quicktime'
    )
    visit_with_auth "/movies/#{movie.id}/edit", 'kimura'
    assert_equal '動画編集 | FBC', title
  end

  test 'show ghost icon and ghost text when the movie-author was deleted' do
    movie = movies(:movie4)
    # Ensure the movie has an attached file for the test
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
      filename: 'movie.mp4',
      content_type: 'video/mp4'
    )
    visit_with_auth "/movies/#{movie.id}", 'komagata'
    within '.a-meta.is-creator' do
      assert_text 'ghost'
      img = find('img')
      assert_match(/ghost-\w+\.png$/, img.native['src'])
    end
  end
end
