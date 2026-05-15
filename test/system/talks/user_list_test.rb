# frozen_string_literal: true

require 'application_system_test_case'

module Talks
  class UserListTest < ApplicationSystemTestCase
    test 'a list of current students is displayed' do
      user = users(:hajime)
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth '/talks?target=student_and_trainee', 'komagata'
      assert_text "#{decorated_user.long_name} さんの相談部屋"
    end

    test 'a list of graduates is displayed' do
      user = users(:sotugyou)
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth '/talks?target=graduate', 'komagata'
      assert_text "#{decorated_user.long_name} さんの相談部屋"
    end

    test 'a list of advisers is displayed' do
      user = users(:advijirou)
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth '/talks?target=adviser', 'komagata'
      assert_text "#{decorated_user.long_name} さんの相談部屋"
    end

    test 'a list of mentors is displayed' do
      user = users(:machida)
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth '/talks?target=mentor', 'komagata'
      assert_text "#{decorated_user.long_name} さんの相談部屋"
    end

    test 'a list of trainees is displayed' do
      user = users(:kensyu)
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth '/talks?target=trainee', 'komagata'
      assert_text "#{decorated_user.long_name} さんの相談部屋"
    end

    test 'a list of retire users is displayed' do
      user = users(:yameo)
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth '/talks?target=retired', 'komagata'
      assert_text "#{decorated_user.long_name} さんの相談部屋"
    end

    test 'Display number of comments, detail of lastest comment user' do
      visit_with_auth '/talks?target=student_and_trainee', 'komagata'
      within('.card-list-item-meta') do
        assert_text 'コメント'
        assert_selector 'img.a-user-icon'
        assert_text '（1）'
        assert_text '2019年01月02日(水) 00:00'
        assert_text '（hajime）'
      end
    end
  end
end
