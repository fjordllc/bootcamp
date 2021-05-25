# frozen_string_literal: true

require 'application_system_test_case'

class PracticesTest < ApplicationSystemTestCase
  test 'show practice' do
    login_user 'hatsuno', 'testtest'
    visit "/practices/#{practices(:practice1).id}"
    assert_equal 'OS X Mountain Lionをクリーンインストールする | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show link to all practices with same category' do
    login_user 'hatsuno', 'testtest'
    user = users(:hatsuno)
    practice1 = practices(:practice1)
    category = practice1.category(user.course)
    visit "/practices/#{practice1.id}"
    category.practices.each do |practice|
      assert has_link? practice.title
    end
  end

  test 'finish a practice' do
    login_user 'komagata', 'testtest'

    visit "/practices/#{practices(:practice1).id}"
    find('#js-complete').click
    assert_not has_link? '完了'
  end

  test "show [提出物を作る] or [提出物] link if user don't have to submit product" do
    login_user 'machida', 'testtest'

    visit "/practices/#{practices(:practice1).id}"
    assert_link '提出物を作る'
  end

  test "don't show [提出物を作る] link if user don't have to submit product" do
    login_user 'yamada', 'testtest'

    visit "/practices/#{practices(:practice1).id}"
    assert_no_link '提出物を作る'
  end

  test "only show when user isn't admin " do
    login_user 'yamada', 'testtest'

    visit "/practices/#{practices(:practice1).id}/edit"
    assert_not_equal 'プラクティス編集', title
  end

  test 'create practice' do
    login_user 'komagata', 'testtest'
    visit '/practices/new'
    within 'form[name=practice]' do
      fill_in 'practice[title]', with: 'テストプラクティス'
      check categories(:category1).name, allow_label_click: true
      fill_in 'practice[description]', with: 'テストの内容です'
      within '#reference_books' do
        click_link '追加'
        fill_in 'タイトル', with: 'テストの参考書籍タイトル'
        fill_in 'ASIN', with: 'テストの参考書籍ASIN'
        click_link '削除'
        click_link '追加'
        fill_in 'タイトル', with: 'テストの参考書籍タイトル2'
        fill_in 'ASIN', with: 'テストの参考書籍ASIN2'
      end
      fill_in 'practice[goal]', with: 'テストのゴールの内容です'
      fill_in 'practice[memo]', with: 'テストのメンター向けメモの内容です'
      click_button '登録する'
    end
    assert_text 'プラクティスを作成しました'
  end

  test 'update practice' do
    login_user 'komagata', 'testtest'
    practice = practices(:practice2)
    product = products(:product3)
    visit "/practices/#{practice.id}/edit"
    within 'form[name=practice]' do
      fill_in 'practice[title]', with: 'テストプラクティス'
      fill_in 'practice[memo]', with: 'メンター向けのメモの内容です'
      within '#reference_books' do
        click_link '追加'
        fill_in 'タイトル', with: 'プロを目指す人のためのRuby入門'
        fill_in 'ASIN', with: 'B077Q8BXHC'
      end
      click_button '更新する'
    end
    assert_text 'プラクティスを更新しました'
    visit "/products/#{product.id}"
    wait_for_vuejs
    find('#side-tabs-nav-2').click
    assert_text 'メンター向けのメモの内容です'
  end

  test 'category button link to courses/practices#index with category fragment' do
    login_user 'komagata', 'testtest'
    practice = practices(:practice1)
    user = users(:komagata)
    category = practice.category(user.course)
    visit "/practices/#{practice.id}"
    within '.page-header-actions' do
      click_link 'プラクティス一覧'
    end
    assert_current_path course_practices_path(user.course)
    assert_equal "category-#{category.id}", URI.parse(current_url).fragment
  end

  test 'add a reference book' do
    login_user 'komagata', 'testtest'
    practice = practices(:practice2)
    visit "/practices/#{practice.id}/edit"
    within '#reference_books' do
      click_link '追加'
      fill_in 'タイトル', with: 'プロを目指す人のRuby入門', match: :prefer_exact
      fill_in 'ASIN', with: 'B077Q8BXHC', match: :prefer_exact
    end
    click_button '更新する'
  end

  test 'update a reference book' do
    login_user 'komagata', 'testtest'
    practice = practices(:practice2)
    visit "/practices/#{practice.id}/edit"
    within '#reference_books' do
      fill_in 'タイトル', with: 'プロを目指す人のRuby入門'
      fill_in 'ASIN', with: 'B077Q8BXHC'
    end
    click_button '更新する'
  end

  test 'show setting for completed percentage' do
    login_user 'komagata', 'testtest'
    visit '/practices/new'
    assert_text '進捗の計算'
  end

  test 'change status' do
    login_user 'hatsuno', 'testtest'
    practice = practices(:practice1)
    visit "/practices/#{practice.id}"
    first('.js-started').click
    sleep 5
    assert_equal 'started', practice.status(users(:hatsuno))
  end

  test 'valid is_startable_practice' do
    login_user 'hatsuno', 'testtest'
    practice = practices(:practice1)
    visit "/practices/#{practice.id}"
    first('.js-started').click
    sleep 5
    assert_equal 'started', practice.status(users(:hatsuno))

    practice = practices(:practice2)
    visit "/practices/#{practice.id}"
    first('.js-started').click
    sleep 5
    assert_equal page.driver.browser.switch_to.alert.text, "すでに着手しているプラクティスがあります。\n提出物を提出するか完了すると新しいプラクティスを開始できます。"
    page.driver.browser.switch_to.alert.accept
  end

  test 'show other practices' do
    login_user 'kimura', 'testtest'
    practice = practices(:practice2)
    visit "/practices/#{practice.id}"
    titles = all('.page-nav__item-link').map(&:text)
    index1 = titles.rindex 'Terminalの基礎を覚える'
    index2 = titles.rindex 'Debianをインストールする'
    assert index1 < index2
  end
end
