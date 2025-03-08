# frozen_string_literal: true

module StripeHelper
  def fill_stripe_element(card, exp, cvc)
    card_iframe = find('iframe[name^="__privateStripeFrame"]', wait: 10)

    within_frame card_iframe do
      card_field = find_field('cardnumber', wait: 10)
      fill_field_carefully(card_field, card)

      exp_field = find_field('exp-date', wait: 5)
      fill_field_carefully(exp_field, exp)

      cvc_field = find_field('cvc', wait: 5)
      fill_field_carefully(cvc_field, cvc)
    end

    page.has_no_css?('iframe[name^="__privateStripeFrame"]', wait: 5)
  end

  private

  def fill_field_carefully(field, value)
    field.clear if field.value.present?
    field.send_keys(value)

    return if field.value.include?(value.gsub(/\s+/, ''))

    field.clear
    value.chars.each do |char|
      field.send_keys(char)
    end
  end
end
