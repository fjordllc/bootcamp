# frozen_string_literal: true

module JavascriptHelper
  # Helper method to wait for JavaScript components to be fully loaded
  def wait_for_javascript_components
    # Wait for Vue.js components to be mounted
    assert_no_selector('.loading-placeholder')

    # Wait for any loading states to complete
    assert_no_selector('[data-loading="true"]')
  end
end
