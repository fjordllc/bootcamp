# frozen_string_literal: true

require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  test 'has_audio? returns false when no audio stream' do
    movie = movies(:movie1)
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
      filename: 'movie.mp4',
      content_type: 'video/mp4'
    )

    assert_not(movie.audio?)
  end

  test 'has_audio? returns true when audio stream present' do
    movie = movies(:movie1)
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie_with_silent_audio.mp4')),
      filename: 'movie_with_silent_audio.mp4',
      content_type: 'video/mp4'
    )

    assert(movie.audio?)
  end
end
