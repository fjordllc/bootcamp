# frozen_string_literal: true

module JavascriptHelper
  # Helper method to wait for JavaScript components to be fully loaded
  def wait_for_javascript_components
    # Wait for Vue.js components to be mounted
    assert_no_selector('.loading-placeholder')

    # Wait for any loading states to complete
    assert_no_selector('[data-loading="true"]')
  end

  # Memory-efficient autocomplete input helper
  # This avoids the memory leak caused by repeated find() calls in a loop
  # by using JavaScript to check the textarea value directly
  def fill_in_with_autocomplete(selector, input_text:, expected_value:, wait: 5)
    element = find(selector)
    element.set('')
    element.set(input_text)

    # Use Capybara's synchronize to wait for the expected value
    # This is more memory-efficient than repeated find() calls
    Capybara.using_wait_time(wait) do
      page.document.synchronize(wait) do
        current_value = evaluate_script("document.querySelector('#{selector}').value")
        raise Capybara::ElementNotFound, "Expected value '#{expected_value}' but got '#{current_value}'" unless current_value == expected_value
      end
    end
  end
end
