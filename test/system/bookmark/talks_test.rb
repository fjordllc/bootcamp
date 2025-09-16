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
    assert_text "#{@decorated_user.long_name} さんの相談部屋" if page.has_text?(@decorated_user.long_name)

    find('a.pagination__item-link', text: '2').click
    assert_text "#{@decorated_user.long_name} さんの相談部屋"
  end

  test 'show active button when bookmarked talk' do
    visit_with_auth "/talks/#{@talk.id}", 'komagata'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
  end

  test 'show inactive button when not bookmarked talk' do
    visit_with_auth "/talks/#{@talk.id}", 'machida'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'
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

  test 'unbookmark talk' do
    visit_with_auth "/talks/#{@talk.id}", 'komagata'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active'
    find('#bookmark-button').click
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'

    visit '/current_user/bookmarks'
    assert_no_text "#{@decorated_user.long_name} さんの相談部屋"
  end

  test 'hide bookmark button when mentor login' do
    visit_with_auth "/talks/#{talks(:talk6).id}", 'mentormentaro'
    assert_text 'mentormentaroさんの相談部屋'
    assert_no_selector '#bookmark-button'
  end

  test 'hide bookmark button when adviser login' do
    visit_with_auth "/talks/#{talks(:talk4).id}", 'advijirou'
    assert_text 'advijirouさんの相談部屋'
    assert_no_selector '#bookmark-button'
  end

  test 'hide bookmark button when graduate login' do
    visit_with_auth "/talks/#{talks(:talk3).id}", 'sotugyou'
    assert_text 'sotugyouさんの相談部屋'
    assert_no_selector '#bookmark-button'
  end

  test 'hide bookmark button when trainee login' do
    visit_with_auth "/talks/#{talks(:talk11).id}", 'kensyu'
    assert_text 'kensyuさんの相談部屋'
    assert_no_selector '#bookmark-button'
  end

  test 'hide bookmark button when student login' do
    visit_with_auth "/talks/#{talks(:talk7).id}", 'kimura'
    assert_text 'kimuraさんの相談部屋'
    assert_no_selector '#bookmark-button'
  end
end
