# frozen_string_literal: true

module StripeHelper
  def fill_stripe_element(card, exp, cvc)
    # Wait longer for Stripe iframe to load
    card_iframe = find('iframe[name^="__privateStripeFrame"]', wait: 10)

    within_frame card_iframe do
      wait_and_fill_field('cardnumber', card)
      wait_and_fill_field('exp-date', exp)
      wait_and_fill_field('cvc', cvc)
    end

    page.has_no_css?('iframe[name^="__privateStripeFrame"]')
  rescue Capybara::ElementNotFound => e
    puts 'Stripe iframe not found. Available iframes:'
    all('iframe').each_with_index do |iframe, index|
      puts "  #{index}: #{iframe[:name] || iframe[:id] || 'no name/id'}"
    end
    raise e
  end

  private

  def wait_and_fill_field(field_name, value)
    # Wait for Stripe elements to fully load and become visible
    field = nil
    10.times do |attempt|
      # First wait for field to exist
      sleep 1

      # Try to find visible field
      begin
        field = find_field(field_name, visible: true, wait: 1)
        break if field
      rescue Capybara::ElementNotFound
        # Field exists but might not be visible yet, check all fields
        available_fields = all("input[name=\"#{field_name}\"]", visible: :all)

        if available_fields.any?
          puts "Attempt #{attempt + 1}: Field '#{field_name}' found but not visible yet, waiting..."
        else
          puts "Attempt #{attempt + 1}: Field '#{field_name}' not found at all, waiting..."
        end

        next if attempt < 9 # Continue trying
      end
    end

    unless field
      puts "Field '#{field_name}' not found or not visible after 10 attempts. Available fields:"
      all('input', visible: :all).each_with_index do |input, index|
        puts "  #{index}: name='#{input[:name]}' id='#{input[:id]}' placeholder='#{input[:placeholder]}' type='#{input[:type]}' visible='#{input.visible?}'"
      end
      raise Capybara::ElementNotFound, "Field '#{field_name}' not found or not visible"
    end

    wait_until_field_ready(field)

    value.chars.each do |char|
      field.send_keys(char)
      sleep 0.05
    end

    sleep 0.2
  end

  def wait_until_field_ready(field)
    max_attempts = 5
    attempts = 0

    while attempts < max_attempts
      begin
        field.tag_name
        return true
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        attempts += 1
        sleep 0.2
        next
      end
    end

    false
  end
end
