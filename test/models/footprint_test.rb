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

  test 'find_or_create_for handles race conditions' do
    user2 = users(:machida)
    
    # Mock a race condition by attempting to create the same footprint twice
    footprint1 = Footprint.find_or_create_for(@resource, user2)
    footprint2 = Footprint.find_or_create_for(@resource, user2)
    
    # Both calls should return the same footprint object (by ID)
    assert_equal footprint1.id, footprint2.id
    
    # Only one footprint should exist in the database
    count = Footprint.where(footprintable: @resource, user: user2).count
    assert_equal 1, count
  end

  test 'find_or_create_for returns nil when footprintable user is the same as current user' do
    # When the resource owner is the same as the current user, no footprint should be created
    result = Footprint.find_or_create_for(@resource, @user)
    assert_nil result
    
    # No footprint should exist in the database
    count = Footprint.where(footprintable: @resource, user: @user).count
    assert_equal 0, count
  end
end
