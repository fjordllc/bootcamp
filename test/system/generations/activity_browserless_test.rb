# frozen_string_literal: true

require 'browserless_system_test_case'

module Generations
  class ActivityBrowserlessTest < BrowserlessSystemTestCase
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
