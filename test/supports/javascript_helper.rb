# frozen_string_literal: true

module JavascriptHelper
  # Helper method to wait for JavaScript components to be fully loaded
  def wait_for_javascript_components
    # Wait for Vue.js components to be mounted
    assert_no_selector('.loading-placeholder')

    # Wait for any loading states to complete
    assert_no_selector('[data-loading="true"]')
  end

  # Helper method to wait for Choices.js to be initialized
  def wait_for_choices_js
    # Wait for select element to exist first
    assert_selector('#js-choices-single-select', wait: 5)
    # Then wait for Choices.js to transform it or use original select element
    if has_selector?('.choices__inner', wait: 2)
      # Choices.js is working
      true
    else
      # Choices.js failed, use original select element
      puts "Warning: Choices.js did not initialize, falling back to original select element"
      false
    end
  end
end
