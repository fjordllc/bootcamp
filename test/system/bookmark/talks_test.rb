# frozen_string_literal: true

require 'application_system_test_case'

class Bookmark::TalkTest < ApplicationSystemTestCase
  setup do
    @talk = talks(:talk1)
    @user = @talk.user
    @decorated_user = ActiveDecorator::Decorator.instance.decorate(@user)
  end

  test 'show talk bookmark on lists' do
    visit_with_auth '/current_user/bookmarks', 'komagata'
    assert_selector '.card-list-item'
    find_all('a.pagination__item-link', text: '2').first.click if !page.has_text?("#{@decorated_user.long_name} さんの相談部屋", wait: 0)

    assert_text "#{@decorated_user.long_name} さんの相談部屋"
  end

  test 'bookmark talk' do
    visit_with_auth "/talks/#{@talk.id}", 'machida'
    wait_for_javascript_components
    find('#bookmark-button').click
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'

    visit '/current_user/bookmarks'
    assert_text "#{@decorated_user.long_name} さんの相談部屋"
  end
end
