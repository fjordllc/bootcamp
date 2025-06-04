# frozen_string_literal: true

module StripeHelper
  def fill_stripe_element(card, exp, cvc)
    card_iframe = find('iframe[name^="__privateStripeFrame"]')

    within_frame card_iframe do
      wait_and_fill_field('cardnumber', card)
      wait_and_fill_field('exp-date', exp)
      wait_and_fill_field('cvc', cvc)
    end

    page.has_no_css?('iframe[name^="__privateStripeFrame"]')
  end

  private

  def wait_and_fill_field(field_name, value)
    field = find_field(field_name)
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
