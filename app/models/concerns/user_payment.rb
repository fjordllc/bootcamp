# frozen_string_literal: true

# ユーザーの支払い方法に関する責務をまとめたもの。
module UserPayment
  extend ActiveSupport::Concern

  included do
    validates :invoice_payment, inclusion: { in: [true], message: 'にチェックを入れてください。' }, if: -> { role == 'trainee_invoice_payment' }
    validates :invoice_payment, inclusion: { in: [true],
                                             message: 'か「クレジットカード払い」のいずれかを選択してください。' },
                                if: -> { role == 'trainee_select_a_payment_method' && !credit_card_payment }
  end
end
