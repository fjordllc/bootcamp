# frozen_string_literal: true

require 'application_system_test_case'

class InvoicePaymentTest < ApplicationSystemTestCase
  test 'not invoice payment user when invoice_payment is false' do
    user = users(:kimura)
    user.invoice_payment = true

    visit_with_auth edit_admin_user_path(user), 'komagata'
    uncheck '請求書払いのユーザーである', allow_label_click: true
    click_on '更新する'

    assert_not user.reload.invoice_payment
  end

  test 'invoice payment user when invoice_payment is true' do
    user = users(:kimura)

    visit_with_auth edit_admin_user_path(user), 'komagata'
    check '請求書払いのユーザーである', allow_label_click: true
    click_on '更新する'

    assert user.reload.invoice_payment
  end
end
