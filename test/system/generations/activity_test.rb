# frozen_string_literal: true

require 'application_system_test_case'

module Generations
  class ActivityTest < ApplicationSystemTestCase
    test 'navigates to user activity when clicking count link' do
      user = users(:kimura)

      visit_with_auth generation_path(user.generation), 'kimura'

      within('.users-item', text: user.name) do
        assert_selector "a[href='/users/#{user.id}/reports']", text: '1'
        within('.card-counts__item-inner', text: '日報') do
          click_link user.reports.count.to_s
        end
        assert_current_path("/users/#{user.id}/reports")
      end

      visit generation_path(user.generation)

      within('.users-item', text: user.name) do
        assert_selector "a[href='/users/#{user.id}/products']", text: '11'
        within('.card-counts__item-inner', text: '提出物') do
          click_link user.products.count.to_s
        end
        assert_current_path("/users/#{user.id}/products")
      end

      visit generation_path(user.generation)

      within('.users-item', text: user.name) do
        assert_selector "a[href='/users/#{user.id}/questions']", text: '4'
        within('.card-counts__item-inner', text: '質問') do
          click_link user.questions.count.to_s
        end
        assert_current_path("/users/#{user.id}/questions")
      end
    end
  end
end
