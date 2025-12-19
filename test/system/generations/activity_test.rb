# frozen_string_literal: true

require 'application_system_test_case'

module Generations
  class ActivityTest < ApplicationSystemTestCase
    test 'progress bar for graduated students should be 100%' do
      user = users(:sotugyou)

      visit_with_auth generation_path(user.generation), 'sotugyou'

      within('.users-item', text: user.name) do
        assert_text '100%'
      end
    end

    test 'progress bar for students who have not completed a single practice is 0%' do
      user = users(:hatsuno)

      visit_with_auth generation_path(user.generation), 'hatsuno'

      within('.users-item', text: user.name) do
        assert_text '0%'
      end
    end

    test 'no activity count is displayed except for students and trainees' do
      user = users(:komagata)

      visit_with_auth generation_path(user.generation), 'komagata'

      within('.users-item', text: user.name) do
        assert_no_selector '.card-counts'
      end
    end

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

    test 'shows 0 without link when user has no activity' do
      user = users(:hatsuno)
      visit_with_auth generation_path(user.generation), 'hatsuno'

      within('.users-item', text: user.name) do
        within('.card-counts__item-inner', text: 'コメント') do
          assert_selector '.is-empty'
          assert_text '0'
        end

        within('.card-counts__item-inner', text: '回答') do
          assert_selector '.is-empty'
          assert_text '0'
        end
      end
    end
  end
end
