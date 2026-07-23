# frozen_string_literal: true

require 'test_helper'
require 'rake'

class BootcampTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?('bootcamp:oneshot:cloudbuild')
    Rake::Task['bootcamp:oneshot:cloudbuild'].reenable
  end

  test 'cloudbuild generates only movie thumbnails' do
    thumbnail_generated = false
    smart_search_task = Rake::Task['smart_search:generate_all']

    smart_search_task.stub(:invoke, -> { flunk 'Smart search should not be generated' }) do
      BulkGenerateMovieThumbnailJob.stub(:perform_now, -> { thumbnail_generated = true }) do
        Rake::Task['bootcamp:oneshot:cloudbuild'].invoke
      end
    end

    assert thumbnail_generated
  end
end
