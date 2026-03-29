# frozen_string_literal: true

require 'application_system_test_case'

class PracticesTest < ApplicationSystemTestCase
  test 'show practice' do
    visit_with_auth "/practices/#{practices(:practice1).id}", 'hatsuno'
    assert_equal 'プラクティス OS X Mountain Lionをクリーンインストールする | FBC', title
  end

  test 'show link to all practices with same category' do
    user = users(:hatsuno)
    practice1 = practices(:practice1)
    category = practice1.category(user.course)
    visit_with_auth "/practices/#{practice1.id}", 'hatsuno'
    category.practices.each do |practice|
      assert has_link? practice.title
    end
  end

  test 'finish a practice' do
    visit_with_auth "/practices/#{practices(:practice3).id}", 'komagata'
    find('#js-complete').click
    assert_not has_link? '修了'
  end

  test "show [提出物を作る] or [提出物] link if user don't have to submit product" do
    visit_with_auth "/practices/#{practices(:practice1).id}", 'machida'
    assert_link '提出物を作る'
  end

  test "don't show [提出物を作る] link if user don't have to submit product" do
    visit_with_auth "/practices/#{practices(:practice1).id}", 'mentormentaro'
    assert_no_link '提出物を作る'
  end

  test 'can see tweet button when current_user has completed a practice' do
    visit_with_auth "/practices/#{practices(:practice1).id}", 'kimura'
    assert_text 'Xに修了ポストする'

    find(:label, 'Xに修了ポストする').click
    assert_text '喜びをXにポストする！'
  end

  test 'category button link to courses/practices#index with category fragment' do
    practice = practices(:practice1)
    user = users(:komagata)
    category = practice.category(user.course)
    visit_with_auth "/practices/#{practice.id}", 'komagata'
    within '.page-header-actions' do
      click_link 'プラクティス一覧'
    end
    assert_current_path course_practices_path(user.course)
    assert_equal "category-#{category.id}", URI.parse(current_url).fragment
  end

  # 画面上では更新の完了がわからないため、やむを得ずsleepする
  # 注意）安易に使用しないこと!! https://bootcamp.fjord.jp/pages/use-assert-text-instead-of-wait-for-vuejs
  def wait_for_status_change
    sleep 1
  end

  test 'change status' do
    practice = practices(:practice1)
    visit_with_auth "/practices/#{practice.id}", 'hatsuno'
    first('.js-started').click
    wait_for_status_change
    assert_equal 'started', practice.status(users(:hatsuno))
  end

  test 'show other practices' do
    practice = practices(:practice2)
    visit_with_auth "/practices/#{practice.id}", 'kimura'
    titles = all('.page-nav__item-link').map(&:text)
    index1 = titles.rindex 'Terminalの基礎を覚える'
    index2 = titles.rindex 'Debianをインストールする'
    assert index1 < index2
  end

  test 'show last updated user icon' do
    visit_with_auth "/practices/#{practices(:practice55).id}", 'hajime'
    within '.thread-header__user-icon-link' do
      assert_selector 'img[alt="komagata (Komagata Masaki): 管理者、メンター"]'
    end
  end

  test 'add all questions to questions tab on practices page and display all questions default' do
    practice = practices(:practice1)
    visit_with_auth "/practices/#{practice.id}/questions", 'komagata'
    assert_text '質問 （12）'
    assert_text '全ての質問'
    assert_text '解決済み'
    assert_text '未解決'
    assert_equal practice.questions.length, 12
  end
end
