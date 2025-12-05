# frozen_string_literal: true

require 'application_system_test_case'

module Talks
  class ActionCompletedTest < ApplicationSystemTestCase
    test 'a talk room is shown up on action uncompleted tab when users except admin comments there' do
      user = users(:kimura)
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth "/talks/#{user.talk.id}", 'kimura'
      within('.thread-comment-form__form') do
        fill_in('new_comment[description]', with: 'test')
      end
      all('.a-form-tabs__tab.js-tabs__tab')[1].click
      assert_text 'test'
      click_button 'コメントする'

      logout
      visit_with_auth '/talks', 'komagata'
      find('.page-tabs__item-link', text: '未対応').click
      assert_text "#{decorated_user.long_name} さんの相談部屋"
    end

    test 'a talk room is not removed from action uncompleted tab when admin comments there' do
      user = users(:with_hyphen)
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth "/talks/#{user.talk.id}", 'komagata'
      within('.thread-comment-form__form') do
        fill_in('new_comment[description]', with: 'test')
      end
      all('.a-form-tabs__tab.js-tabs__tab')[1].click
      assert_text 'test'
      click_button 'コメントする'
      visit '/talks/action_uncompleted'
      assert_text "#{decorated_user.long_name} さんの相談部屋"
    end

    test 'it will be action completed when check action completed ' do
      user = users(:with_hyphen)
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth '/talks/action_uncompleted', 'komagata'
      assert_text "#{decorated_user.long_name} さんの相談部屋"

      visit "/talks/#{user.talk.id}"
      find('.check-button').click
      assert_text '対応済みにしました'
      assert_text '対応済です'
      visit '/talks/action_uncompleted'
      assert_no_text "#{decorated_user.long_name} さんの相談部屋"
    end

    test 'it will be action uncompleted when check action completed ' do
      user = users(:kimura)
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth '/talks/action_uncompleted', 'komagata'
      assert_no_text "#{decorated_user.long_name} さんの相談部屋"

      visit "/talks/#{user.talk.id}"
      find('.check-button').click
      assert_text '未対応にしました'
      assert_text '対応済にする'
      visit '/talks/action_uncompleted'
      assert_text "#{decorated_user.long_name} さんの相談部屋"
    end
  end
end
