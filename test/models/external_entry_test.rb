# frozen_string_literal: true

require 'test_helper'

class ExternalEntryTest < ActiveSupport::TestCase
  test 'thumbnail_url' do
    external_entry = external_entries(:external_entry1)
    assert_equal '/images/external_entries/thumbnails/blank.svg', external_entry.thumbnail_url
  end
end
