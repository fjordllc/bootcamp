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

    # Wait for select element to exist first
    assert_selector('#js-choices-single-select', wait: 5)
    # Then wait for Choices.js to transform it or use original select element
    if has_selector?('.choices__inner', wait: 2)
      # Choices.js is working
      true
    else
      # Choices.js failed, use original select element
      puts 'Warning: Choices.js did not initialize, falling back to original select element'
      false
    end
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

    # Check if required libraries are available in window
    tagify_available = page.evaluate_script('typeof window.Tagify !== "undefined"')
    choices_available = page.evaluate_script('typeof window.Choices !== "undefined"')
    react_available = page.evaluate_script('typeof window.React !== "undefined"')
    stripe_available = page.evaluate_script('typeof window.Stripe !== "undefined"')

    puts "Tagify available: #{tagify_available}"
    puts "Choices available: #{choices_available}"
    puts "React available: #{react_available}"
    puts "Stripe available: #{stripe_available}"

    # Check if DOM elements exist
    tagify_elements = page.all('.tagify', visible: :all).count
    choices_elements = page.all('.choices', visible: :all).count
    stripe_frames = page.all('iframe[name^="__privateStripeFrame"]', visible: :all).count
    select_elements = page.all('select#js-choices-single-select', visible: :all).count

    puts "Tagify elements found: #{tagify_elements}"
    puts "Choices elements found: #{choices_elements}"
    puts "Stripe frames found: #{stripe_frames}"
    puts "Select elements found: #{select_elements}"

    # Check page load status
    ready_state = page.evaluate_script('document.readyState')
    puts "Document ready state: #{ready_state}"

    # Check for JavaScript errors in console
    begin
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

    puts "=====================================\n"
  rescue StandardError => e
    puts "Could not get JavaScript debug info: #{e.message}"
  end
end
