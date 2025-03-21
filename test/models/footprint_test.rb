# frozen_string_literal: true

require 'test_helper'

class FootprintTest < ActiveSupport::TestCase
  setup do
    @user = users(:komagata)
    @resource = announcements(:announcement1)
  end

  test 'fetch_for_resource returns footprints associated with the resource' do
    user2 = users(:machida)
    Footprint.find_or_create_by(footprintable: @resource, user: user2)

    footprints = Footprint.fetch_for_resource(@resource)
    assert_equal 1, footprints.count
    assert_equal user2, footprints.first.user
  end

  test 'fetch_for_resource excludes footprints of the resource owner' do
    Footprint.find_or_create_by(footprintable: @resource, user: @user)

    footprints = Footprint.fetch_for_resource(@resource)
    assert_equal 0, footprints.count
  end

  test 'count_for_resource returns the correct count of footprints for the resource' do
    user2 = users(:machida)
    Footprint.find_or_create_by(footprintable: @resource, user: user2)
    Footprint.find_or_create_by(footprintable: @resource, user: @user)

    count = Footprint.count_for_resource(@resource)
    assert_equal 1, count
  end
end
