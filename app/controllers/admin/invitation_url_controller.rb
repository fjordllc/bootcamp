# frozen_string_literal: true

class Admin::InvitationUrlController < AdminController
  INVITATION_ROLES = [
    [I18n.t('invitation_role.adviser'), :adviser],
    [I18n.t('invitation_role.trainee', payment_method: '請求書払い'), :trainee_invoice_payment],
    [I18n.t('invitation_role.trainee', payment_method: 'クレジットカード払い'), :trainee_credit_card_payment],
    [I18n.t('invitation_role.trainee', payment_method: '支払い方法を選択'), :trainee_select_a_payment_method],
    [I18n.t('invitation_role.mentor'), :mentor]
  ].freeze

  def index
    @invitation_roles = INVITATION_ROLES
    @invitation_url_template = new_user_url(
      company_id: 'dummy_company_id',
      role: 'dummy_role',
      course_id: 'dummy_course_id',
      token: ENV['TOKEN'] || 'token'
    )
  end
end
