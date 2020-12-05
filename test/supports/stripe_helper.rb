# frozen_string_literal: true

module StripeHelper
  def fill_stripe_element(card, exp, cvc, postal)
    card_iframe = all('iframe')[0]

    within_frame card_iframe do
      card.chars.each do |piece|
        find_field('cardnumber').send_keys(piece)
      end

      exp.chars.each do |piece|
        find_field('exp-date').send_keys(piece)
      end

      cvc.chars.each do |piece|
        find_field('cvc').send_keys(piece)
      end

      postal.chars.each do |piece|
        find_field('postal').send_keys(piece)
      end
    end
  end
end
