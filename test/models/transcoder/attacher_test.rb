# frozen_string_literal: true

require 'test_helper'
require 'google/cloud/storage'

module Transcoder
  class AttacherTest < ActiveSupport::TestCase
    test '#perform' do
      movie = movies(:movie5)

      file_mock = Minitest::Mock.new
      file_mock.expect :download, StringIO.new('dummy content')
      file_mock.expect :delete, nil

      bucket_mock = Minitest::Mock.new
      bucket_mock.expect :file, file_mock, [String]

      storage_mock = Minitest::Mock.new
      storage_mock.expect :bucket, bucket_mock, ['test-bucket']

      Google::Cloud::Storage.stub :new, storage_mock do
        attacher = Transcoder::Attacher.new(movie)
        attacher.instance_variable_set(:@bucket_name, 'test-bucket')

        attacher.perform

        assert movie.movie_data.attached?, 'movie_data should be attached'
      end
      [file_mock, bucket_mock, storage_mock].each(&:verify)
    end
  end
end
