# frozen_string_literal: true

module UserValidations4
  extend ActiveSupport::Concern

  included do
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
    validates :name, presence: true
    validates :description, presence: true
    validates :nda, presence: true
    validates :password, length: { minimum: 4 }, confirmation: true, if: :password_required?
    validates :mail_notification, inclusion: { in: [true, false] }
    validates :show_mentor_profile, inclusion: { in: [true, false] }
    validates :github_id, uniqueness: true, allow_nil: true
    validates :other_editor, presence: true, if: -> { editor == 'other_editor' }
    validates :other_referral_source, presence: true, if: -> { referral_source == 'other' }
    validates :invoice_payment, inclusion: { in: [true], message: 'にチェックを入れてください。' }, if: -> { role == 'trainee_invoice_payment' }
    validates :invoice_payment, inclusion: { in: [true],
                                             message: 'か「クレジットカード払い」のいずれかを選択してください。' },
                                if: -> { role == 'trainee_select_a_payment_method' && !credit_card_payment }
  end
end
