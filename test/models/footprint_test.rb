# frozen_string_literal: true

require 'test_helper'

class FootprintTest < ActiveSupport::TestCase
  setup do
    @user = users(:komagata)
    @resource = announcements(:announcement1)
  end

  test 'create_on_resource creates a footprint for the resource and user' do
    assert_difference 'Footprint.count', 1 do
      Footprint.create_on_resource(@resource, @user)
    end
  end

  test 'create_on_resource does not create duplicate footprints for the same resource and user' do
    Footprint.create_on_resource(@resource, @user)
    assert_no_difference 'Footprint.count' do
      Footprint.create_on_resource(@resource, @user)
    end
  end

  test 'fetch_for_resource returns footprints associated with the resource' do
    user2 = users(:machida)
    Footprint.create_on_resource(@resource, user2)

    footprints = Footprint.fetch_for_resource(@resource)
    assert_equal 1, footprints.count
    assert_equal user2, footprints.first.user
  end

  test 'fetch_for_resource excludes footprints of the resource owner' do
    Footprint.create_on_resource(@resource, @user)

    footprints = Footprint.fetch_for_resource(@resource)
    assert_equal 0, footprints.count
  end

  test 'count_for_resource returns the correct count of footprints for the resource' do
    user2 = users(:machida)
    Footprint.create_on_resource(@resource, user2)
    Footprint.create_on_resource(@resource, @user)

    count = Footprint.count_for_resource(@resource)
    assert_equal 1, count
  end
end
