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
    field = wait_for_visible_field(field_name)
    fill_field_slowly(field, value)
  end

  def wait_for_visible_field(field_name)
    field = find_visible_field_with_retry(field_name)
    raise_field_not_found_error(field_name) unless field

    wait_until_field_ready(field)
    field
  end

  def find_visible_field_with_retry(field_name)
    field = nil
    10.times do |attempt|
      sleep 1
      field = try_find_visible_field(field_name, attempt)
      break if field
    end
    field
  end

  def try_find_visible_field(field_name, attempt)
    find_field(field_name, visible: true, wait: 1)
  rescue Capybara::ElementNotFound
    log_field_search_attempt(field_name, attempt)
    nil
  end

  def log_field_search_attempt(field_name, attempt)
    available_fields = all("input[name=\"#{field_name}\"]", visible: :all)

    if available_fields.any?
      puts "Attempt #{attempt + 1}: Field '#{field_name}' found but not visible yet, waiting..."
    else
      puts "Attempt #{attempt + 1}: Field '#{field_name}' not found at all, waiting..."
    end
  end

  def raise_field_not_found_error(field_name)
    puts "Field '#{field_name}' not found or not visible after 10 attempts. Available fields:"
    all('input', visible: :all).each_with_index do |input, index|
      puts "  #{index}: name='#{input[:name]}' id='#{input[:id]}' placeholder='#{input[:placeholder]}' type='#{input[:type]}' visible='#{input.visible?}'"
    end
    raise Capybara::ElementNotFound, "Field '#{field_name}' not found or not visible"
  end

  def fill_field_slowly(field, value)
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
