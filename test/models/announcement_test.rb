# frozen_string_literal: true

require "test_helper"

class AnnouncementTest < ActiveSupport::TestCase
  test "should be valid" do
    assert announcements(:announcement_1).valid?
  end

  test "should be invalid when title is blank" do
    announcement = announcements(:announcement_1)
    announcement.title = ""
    assert announcement.invalid?
  end

  test "should be invalid when description is blank" do
    announcement = announcements(:announcement_1)
    announcement.description = ""
    assert announcement.invalid?
  end
end
