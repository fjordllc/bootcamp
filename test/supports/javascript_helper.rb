# frozen_string_literal: true

module JavascriptHelper
  # Helper method to wait for JavaScript components to be fully loaded
  def wait_for_javascript_components
    # Wait for Vue.js components to be mounted
    assert_no_selector('.loading-placeholder')

    # Wait for any loading states to complete
    assert_no_selector('[data-loading="true"]')
  end

  # Wait for bookmark button to be fully loaded
  def wait_for_bookmark_button_loading
    return unless has_selector?('[data-bookmark-button]')

    # Wait for any loading states to complete
    assert_no_selector('[data-bookmark-button][data-loading="true"]')
  end
end
