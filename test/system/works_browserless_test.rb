# frozen_string_literal: true

require 'browserless_system_test_case'

class WorksBrowserlessTest < BrowserlessSystemTestCase
  test 'user can see portfolio list page' do
    visit_with_auth portfolios_path, 'kimura'
    assert_equal 'みんなのポートフォリオ | FBC', title
    assert_selector "meta[property='og:title'][content='みんなのポートフォリオ']", visible: false
    assert_selector 'h2.page-header__title', text: 'みんなのポートフォリオ'
    assert_text works(:work1).title
  end

  test "user can see user's own work" do
    visit_with_auth work_path(works(:work1)), 'kimura'
    assert_text "kimura's app"
  end

  test "user can see other user's work" do
    visit_with_auth work_path(works(:work2)), 'kimura'
    assert_text "hatsuno's app"
    assert_no_text '作品を追加'
  end

  test "show user's profile link" do
    visit_with_auth work_path(works(:work1)), 'kimura'
    assert_link 'kimura', href: "/users/#{users(:kimura).id}"
  end

  test "user can't update other user's work" do
    visit_with_auth work_path(works(:work2)), 'kimura'
    assert_no_text '内容修正'
  end

  test "user can't destroy other user's work" do
    visit_with_auth work_path(works(:work2)), 'kimura'
    assert_no_text '削除'
  end
end
