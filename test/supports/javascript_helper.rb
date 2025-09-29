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
    # Check for JavaScript errors in the browser console
    check_javascript_errors

    # Wait for select element to exist (may be hidden after Choices.js initialization)
    assert_selector('#js-choices-single-select', wait: 5, visible: false)

    # Find the select element and check for Choices.js initialization in its container
    select_element = find('#js-choices-single-select', visible: false)

    # Check if Choices.js has created its wrapper around or near the select element
    # Choices.js typically creates a sibling element with class 'choices'
    if select_element.sibling('.choices', visible: true, wait: 2) ||
       select_element.find(:xpath, './following-sibling::*[@class="choices"]', visible: true, wait: 2) ||
       select_element.find(:xpath, './parent::*//div[@class="choices__inner"]', visible: true, wait: 2)
      # Choices.js is working
      true
    else
      # Choices.js failed, use original select element
      puts 'Warning: Choices.js did not initialize, falling back to original select element'
      false
    end
  rescue Capybara::ElementNotFound
    # If we can't find the elements, fallback
    puts 'Warning: Could not find Choices.js elements, falling back to original select element'
    false
  end

  # Helper method to check for JavaScript errors
  def check_javascript_errors
    errors = page.driver.browser.logs.get(:browser)
                 .select { |log| log.level == 'SEVERE' }

    if errors.any?
      puts 'JavaScript errors detected:'
      errors.each do |error|
        puts "  #{error.message}"
      end
    end
  rescue StandardError => e
    # Ignore if browser doesn't support logging
    puts "Could not check browser logs: #{e.message}"
  end

  def debug_javascript_state
    puts "\n=== JavaScript Debug Information ==="
    debug_library_availability
    debug_dom_elements
    debug_page_load_status
    debug_console_errors
    puts "=====================================\n"
  rescue StandardError => e
    puts "Could not get JavaScript debug info: #{e.message}"
  end

  private

  def debug_library_availability
    tagify_available = page.evaluate_script('typeof window.Tagify !== "undefined"')
    choices_available = page.evaluate_script('typeof window.Choices !== "undefined"')
    react_available = page.evaluate_script('typeof window.React !== "undefined"')
    stripe_available = page.evaluate_script('typeof window.Stripe !== "undefined"')

    puts "Tagify available: #{tagify_available}"
    puts "Choices available: #{choices_available}"
    puts "React available: #{react_available}"
    puts "Stripe available: #{stripe_available}"
  end

  def debug_dom_elements
    tagify_elements = page.all('.tagify', visible: :all).count
    choices_elements = page.all('.choices', visible: :all).count
    stripe_frames = page.all('iframe[name^="__privateStripeFrame"]', visible: :all).count
    select_elements = page.all('select#js-choices-single-select', visible: :all).count

    puts "Tagify elements found: #{tagify_elements}"
    puts "Choices elements found: #{choices_elements}"
    puts "Stripe frames found: #{stripe_frames}"
    puts "Select elements found: #{select_elements}"
  end

  def debug_page_load_status
    ready_state = page.evaluate_script('document.readyState')
    puts "Document ready state: #{ready_state}"
  end

  def debug_console_errors
    console_logs = page.driver.browser.logs.get(:browser)
    error_logs = console_logs.select { |log| %w[SEVERE WARNING].include?(log.level) }

    if error_logs.any?
      puts "\nBrowser console errors/warnings:"
      error_logs.each do |log|
        puts "  [#{log.level}] #{log.message}"
      end
    else
      puts "\nNo severe browser console errors found"
    end
  rescue StandardError => e
    puts "\nCould not check console logs: #{e.message}"
  end
end
