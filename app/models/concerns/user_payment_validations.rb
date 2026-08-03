# frozen_string_literal: true

module UserPaymentValidations
  extend ActiveSupport::Concern

  included do
    validates :other_editor, presence: true, if: -> { editor == 'other_editor' }
    validates :other_referral_source, presence: true, if: -> { referral_source == 'other' }
    validates :invoice_payment, inclusion: { in: [true], message: 'にチェックを入れてください。' }, if: -> { role == 'trainee_invoice_payment' }
    validates :invoice_payment, inclusion: { in: [true],
                                             message: 'か「クレジットカード払い」のいずれかを選択してください。' },
                                if: -> { role == 'trainee_select_a_payment_method' && !credit_card_payment }
  end
end
