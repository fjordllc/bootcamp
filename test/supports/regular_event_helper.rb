# frozen_string_literal: true

module RegularEventHelper
  def wait_for_regular_event_form
    assert_selector 'input[name="regular_event[title]"]:not([disabled])', wait: 20
  end
end
