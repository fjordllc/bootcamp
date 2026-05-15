# frozen_string_literal: true

module AnnouncementHelper
  def wait_for_announcement_form
    assert_selector 'input[name="announcement[title]"]:not([disabled])', wait: 20
  end
end
