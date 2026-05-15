# frozen_string_literal: true

require 'application_system_test_case'

module Reports
  class OrderTest < ApplicationSystemTestCase
    test 'reports are ordered in descending of reported_on' do
      visit_with_auth reports_path, 'kimura'
      precede = reports(:report15).title
      succeed = reports(:report16).title
      assert_text '頑張りました'
      assert_text '頑張れませんでした'
      within '.card-list__items' do
        assert page.text.index(precede) < page.text.index(succeed)
      end
    end

    test 'reports are ordered in descending of created_at if reported_on is same' do
      visit_with_auth reports_path, 'kimura'
      precede = reports(:report18).title
      succeed = reports(:report17).title

      within '.card-list__items' do
        assert page.text.index(precede) < page.text.index(succeed)
      end
    end
  end
end
