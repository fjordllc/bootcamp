# frozen_string_literal: true

require 'application_system_test_case'

class PracticesTest < ApplicationSystemTestCase
  test 'show practice' do
    visit_with_auth "/practices/#{practices(:practice1).id}", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールする | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
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
    visit_with_auth "/practices/#{practices(:practice1).id}", 'komagata'
    find('#js-complete').click
    assert_not has_link? '完了'
  end

  test "show [提出物を作る] or [提出物] link if user don't have to submit product" do
    visit_with_auth "/practices/#{practices(:practice1).id}", 'machida'
    assert_link '提出物を作る'
  end

  test "don't show [提出物を作る] link if user don't have to submit product" do
    visit_with_auth "/practices/#{practices(:practice1).id}", 'yamada'
    assert_no_link '提出物を作る'
  end

  test 'complete and tweet' do
    visit_with_auth "/practices/#{practices(:practice2).id}", 'kimura'
    find('#js-complete').click
    assert_text 'Twitterにシェアする'

    click_link 'Twitterにシェアする'
    switch_to_window(windows.last)
    assert_includes current_url, 'https://twitter.com/intent/tweet'
  end

  test 'can see tweet button when current_user has completed a practice' do
    visit_with_auth "/practices/#{practices(:practice1).id}", 'kimura'
    assert_text '完了Tweetする'

    find('span.switch__label-text').click
    assert_text 'Twitterにシェアする'

    click_link 'Twitterにシェアする'
    switch_to_window(windows.last)
    assert_includes current_url, 'https://twitter.com/intent/tweet'
  end

  test "only show when user isn't admin " do
    visit_with_auth "/practices/#{practices(:practice1).id}/edit", 'yamada'
    assert_not_equal 'プラクティス編集', title
  end

  test 'create practice' do
    visit_with_auth '/practices/new', 'komagata'
    within 'form[name=practice]' do
      fill_in 'practice[title]', with: 'テストプラクティス'
      check categories(:category1).name, allow_label_click: true
      fill_in 'practice[description]', with: 'テストの内容です'
      within '#reference_books' do
        click_link '書籍を追加'
        fill_in 'タイトル', with: 'テストの参考書籍タイトル'
        fill_in '価格', with: '1234'
        fill_in 'URL', with: 'テストの参考書籍ASIN'
        find('.reference-books-form-item__must-read').click
        fill_in '説明', with: 'テストの参考書籍説明'
        find('.reference-books-form__delete-link').click # delete
        click_link '書籍を追加'
        fill_in 'タイトル', with: 'テストの参考書籍タイトル2'
        fill_in '価格', with: '1234'
        fill_in 'URL', with: 'http://example.com'
        find('.reference-books-form-item__must-read').click
        fill_in '説明', with: 'テストの参考書籍説明'
      end
      fill_in 'practice[goal]', with: 'テストのゴールの内容です'
      fill_in 'practice[memo]', with: 'テストのメンター向けメモの内容です'
      click_button '登録する'
    end
    assert_text 'プラクティスを作成しました'
  end

  test 'update practice' do
    practice = practices(:practice2)
    product = products(:product3)
    visit_with_auth "/practices/#{practice.id}/edit", 'komagata'
    within 'form[name=practice]' do
      fill_in 'practice[title]', with: 'テストプラクティス'
      fill_in 'practice[memo]', with: 'メンター向けのメモの内容です'
      within '#reference_books' do
        click_link '追加'
        fill_in 'タイトル', with: 'プロを目指す人のためのRuby入門'
        fill_in '価格', with: '2345'
        fill_in 'URL', with: 'http://example.com'
        find('.reference-books-form-item__must-read').click
        fill_in '説明', with: 'テストの参考書籍説明'
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

  test 'add a reference book' do
    practice = practices(:practice2)
    visit_with_auth "/practices/#{practice.id}/edit", 'komagata'
    within '#reference_books' do
      click_link '追加'
      fill_in 'タイトル', with: 'プロを目指す人のRuby入門', match: :prefer_exact
      fill_in '価格', with: '2345', match: :prefer_exact
      fill_in 'URL', with: 'http://example.com'
      find('.reference-books-form-item__must-read').click
      fill_in '説明', with: 'テストの参考書籍説明'
    end
    click_button '更新する'
  end

  test 'update a reference book' do
    practice = practices(:practice1)
    visit_with_auth "/practices/#{practice.id}/edit", 'komagata'
    within '#reference_books' do
      fill_in 'タイトル', with: 'プロを目指す人のRuby入門'
      fill_in '価格', with: '2345'
      fill_in 'URL', with: 'http://example.com'
      find('.reference-books-form-item__must-read').click
      fill_in '説明', with: 'テストの参考書籍説明'
    end
    click_button '更新する'
  end

  test 'add ogp image' do
    practice = practices(:practice1)
    visit_with_auth "/practices/#{practice.id}/edit", 'komagata'
    attach_file 'practice[ogp_image]', 'test/fixtures/files/practices/ogp_images/1.jpg'
    click_button '更新する'

    visit_with_auth "/practices/#{practice.id}/edit", 'komagata'
    within('form[name=practice]') do
      assert_selector 'img'
    end
  end

  test 'show setting for completed percentage' do
    visit_with_auth '/practices/new', 'komagata'
    assert_text '進捗の計算'
  end

  test 'change status' do
    practice = practices(:practice1)
    visit_with_auth "/practices/#{practice.id}", 'hatsuno'
    first('.js-started').click
    sleep 5
    assert_equal 'started', practice.status(users(:hatsuno))
  end

  test 'valid is_startable_practice' do
    practice = practices(:practice1)
    visit_with_auth "/practices/#{practice.id}", 'hatsuno'
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
    practice = practices(:practice2)
    visit_with_auth "/practices/#{practice.id}", 'kimura'
    titles = all('.page-nav__item-link').map(&:text)
    index1 = titles.rindex 'Terminalの基礎を覚える'
    index2 = titles.rindex 'Debianをインストールする'
    assert index1 < index2
  end

  test 'update practice in the role of mentor' do
    practice = practices(:practice2)
    visit_with_auth "/practices/#{practice.id}/edit", 'yamada'
    within 'form[name=practice]' do
      fill_in 'practice[title]', with: 'テストプラクティス'
      within '#reference_books' do
        click_link '追加'
        fill_in 'タイトル', with: 'プロを目指す人のためのRuby入門'
        fill_in '価格', with: '2345'
        fill_in 'URL', with: 'http://example.com'
        find('.reference-books-form-item__must-read').click
        fill_in '説明', with: 'テストの参考書籍説明'
      end
      click_button '更新する'
    end
    assert_text 'プラクティスを更新しました'
    visit "/practices/#{practice.id}"
    wait_for_vuejs
    assert_equal 'テストプラクティス | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
