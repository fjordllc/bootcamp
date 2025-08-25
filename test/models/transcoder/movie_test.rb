# frozen_string_literal: true
require "test_helper"
require "google/cloud/storage"

module Transcoder
  class MovieTest < ActiveSupport::TestCase
    def build_movie(file_exists: true, fail_gcs_delete: false, fail_gcs_download: false)
      movie = OpenStruct.new(id: 1)
      movie_obj = Transcoder::Movie.new(movie, bucket_name: "dummy", path: "dummy/path")

      movie_obj.define_singleton_method(:file) do
        obj = Object.new
        obj.define_singleton_method(:exists?) { file_exists }
        obj.define_singleton_method(:delete) { raise Google::Cloud::Error, "fail delete" if fail_gcs_delete }
        obj.define_singleton_method(:download) do |path|
          raise Google::Cloud::Error, "fail download" if fail_gcs_download
          File.write(path, "dummy data")
        end
        obj
      end

      movie_obj
    end

    test "data returns tempfile" do
      movie_obj = build_movie(file_exists: true)
      tf = movie_obj.data

      assert tf.is_a?(Tempfile)
      assert_equal "dummy data", tf.read
    end

    test "data raises when file missing" do
      movie_obj = build_movie(file_exists: false)
      error = assert_raises(RuntimeError) { movie_obj.data }
      assert_equal "Transcoded file not found", error.message
    end

    test "data raises on GCS download error" do
      movie_obj = build_movie(file_exists: true, fail_gcs_download: true)
      error = assert_raises(Google::Cloud::Error) { movie_obj.data }
      assert_equal "fail download", error.message
    end

    test "cleanup deletes GCS file and tempfile" do
      movie_obj = build_movie(file_exists: true)
      temp = Tempfile.new("test")
      path = temp.path
      movie_obj.instance_variable_set(:@tempfile, temp)

      assert_silent { movie_obj.cleanup }
      refute File.exist?(path)
    end

    test "cleanup ignores GCS delete errors" do
      movie_obj = build_movie(file_exists: true, fail_gcs_delete: true)
      movie_obj.instance_variable_set(:@tempfile, Tempfile.new("test"))

      assert_silent { movie_obj.cleanup }
    end

    test "cleanup ignores tempfile close errors" do
      movie_obj = build_movie(file_exists: true)
      temp = Tempfile.new("test")
      movie_obj.instance_variable_set(:@tempfile, temp)
      temp.define_singleton_method(:close!) { raise StandardError, "fail" }

      assert_silent { movie_obj.cleanup }
    end
  end
end
