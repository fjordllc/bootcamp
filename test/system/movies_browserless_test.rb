# frozen_string_literal: true

require 'browserless_system_test_case'

class MoviesBrowserlessTest < BrowserlessSystemTestCase
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
end
