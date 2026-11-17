# frozen_string_literal: true

require 'browserless_system_test_case'

class Bookmark::TalkBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @talk = talks(:talk1)
    @user = @talk.user
    @decorated_user = ActiveDecorator::Decorator.instance.decorate(@user)
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
