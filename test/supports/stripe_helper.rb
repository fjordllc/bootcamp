# frozen_string_literal: true

module StripeHelper
  def fill_stripe_element(card, exp, cvc)
    wait_and_fill_stripe_field('cardnumber', card)
    wait_and_fill_stripe_field('exp-date', exp)
    wait_and_fill_stripe_field('cvc', cvc)

    page.has_no_css?('iframe[name^="__privateStripeFrame"]')
  end

  private

  def wait_and_fill_stripe_field(field_name, value)
    field = wait_for_visible_stripe_field(field_name)
    fill_field_slowly(field, value)
  end

  def wait_for_visible_stripe_field(field_name)
    field = find_visible_stripe_field_with_retry(field_name)
    raise_field_not_found_error(field_name) unless field

    wait_until_field_ready(field)
    field
  end

  def find_visible_stripe_field_with_retry(field_name)
    field = nil
    5.times do
      field = find_visible_stripe_field(field_name)
      break if field

      sleep 0.5
    end
    field
  end

  def find_visible_stripe_field(field_name)
    all('iframe[name^="__privateStripeFrame"]').each do |iframe|
      field = find_field_in_frame(iframe, field_name)
      return field if field
    end
    nil
  end

  def find_field_in_frame(iframe, field_name)
    within_frame iframe do
      find_field(field_name, visible: true)
    end
  rescue Capybara::ElementNotFound, Capybara::Playwright::Node::StaleReferenceError
    nil
  end

  def raise_field_not_found_error(field_name)
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
      rescue Capybara::ElementNotFound, Capybara::Playwright::Node::StaleReferenceError
        attempts += 1
        sleep 0.2
        next
      end
    end

    false
  end
end
