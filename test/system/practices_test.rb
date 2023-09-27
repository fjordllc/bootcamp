# frozen_string_literal: true

require 'application_system_test_case'

class PracticesTest < ApplicationSystemTestCase
  test 'show practice' do
    visit_with_auth "/practices/#{practices(:practice1).id}", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールする | FBC', title
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
    assert_text '修了 投稿する'

    find(:label, '修了 投稿する').click
    assert_text '喜びを 投稿する！'
  end

  test "only show when user isn't admin " do
    visit_with_auth "/mentor/practices/#{practices(:practice1).id}/edit", 'mentormentaro'
    assert_not_equal 'プラクティス編集', title
  end

  test 'create practice' do
    visit_with_auth '/mentor/practices/new', 'komagata'
    within 'form[name=practice]' do
      fill_in 'practice[title]', with: 'テストプラクティス'
      check categories(:category1).name, allow_label_click: true
      fill_in 'practice[summary]', with: 'テストの概要です'
      fill_in 'practice[description]', with: 'テストの内容です'
      within '#reference_books' do
        click_link '書籍を選択'
      end
      fill_in 'practice[goal]', with: 'テストのゴールの内容です'
      fill_in 'practice[memo]', with: 'テストのメンター向けメモの内容です'
      click_button '登録する'
    end
    assert_text 'プラクティスを作成しました'
  end

  test 'create practice as a mentor' do
    visit_with_auth '/mentor/practices/new', 'mentormentaro'
    within 'form[name=practice]' do
      fill_in 'practice[title]', with: 'テストプラクティス'
      check categories(:category1).name, allow_label_click: true
      fill_in 'practice[description]', with: 'テストの内容です'
      within '#reference_books' do
        click_link '書籍を選択'
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
    visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
    within 'form[name=practice]' do
      fill_in 'practice[title]', with: 'テストプラクティス'
      fill_in 'practice[memo]', with: 'メンター向けのメモの内容です'
      within '#reference_books' do
        click_link '書籍を選択'
      end
      click_button '更新する'
    end
    assert_text 'プラクティスを更新しました'
    visit "/products/#{product.id}"
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

  test 'add a book' do
    practice = practices(:practice2)
    visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
    within '#reference_books' do
      click_link '書籍を選択'
    end
    click_button '更新する'
  end

  test 'update a book' do
    practice = practices(:practice1)
    visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
    within '#reference_books' do
      find('.choices__list').click
      find('#choices--practice_practices_books_attributes_0_book_id-item-choice-2', text: 'はじめて学ぶソフトウェアのテスト技法').click
    end
    click_button '更新する'
    assert_text 'はじめて学ぶソフトウェアのテスト技法'
  end

  test 'add completion image' do
    practice = practices(:practice1)
    visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
    attach_file 'practice[completion_image]', 'test/fixtures/files/practices/ogp_images/1.jpg', make_visible: true
    click_button '更新する'

    visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
    within('form[name=practice]') do
      assert_selector 'img'
    end
  end

  test 'show setting for completed percentage' do
    visit_with_auth '/mentor/practices/new', 'komagata'
    assert_text '進捗の計算'
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

  test 'valid is_startable_practice' do
    practice = practices(:practice1)
    visit_with_auth "/practices/#{practice.id}", 'hatsuno'
    first('.js-started').click
    wait_for_status_change
    assert_equal 'started', practice.status(users(:hatsuno))

    practice = practices(:practice2)
    visit "/practices/#{practice.id}"
    accept_alert "すでに着手しているプラクティスがあります。\n提出物を提出するか修了すると新しいプラクティスを開始できます。" do
      first('.js-started').click
    end
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
    visit_with_auth "/mentor/practices/#{practice.id}/edit", 'mentormentaro'
    within 'form[name=practice]' do
      fill_in 'practice[title]', with: 'テストプラクティス'
      within '#reference_books' do
        click_link '書籍を選択'
      end
      click_button '更新する'
    end
    assert_text 'プラクティスを更新しました'
    visit "/practices/#{practice.id}"
    assert_equal 'テストプラクティス | FBC', title
  end

  test 'show last updated user icon' do
    visit_with_auth "/practices/#{practices(:practice55).id}", 'hajime'
    within '.thread-header__user-icon-link' do
      assert_selector 'img[alt="komagata (Komagata Masaki): 管理者、メンター"]'
    end
  end

  test 'show/hide memo for mentor' do
    practice = practices(:practice2)
    visit_with_auth "/practices/#{practice.id}", 'komagata'
    assert_text 'メンター向けメモ'
    find(:css, '#checkbox-mentor-mode').set(false)
    assert_no_text 'メンター向けメモ'
  end

  test 'show/hide menu for mentor' do
    practice = practices(:practice2)
    visit_with_auth "/practices/#{practice.id}", 'komagata'
    assert_text '管理者・メンター用メニュー'
    find(:css, '#checkbox-mentor-mode').set(false)
    assert_no_text '管理者・メンター用メニュー'
  end

  test 'add all questions to questions tab on practices page and display all questions default' do
    practice = practices(:practice1)
    visit_with_auth "/practices/#{practice.id}/questions", 'komagata'
    assert_text '質問 （11）'
    assert_text '全ての質問'
    assert_text '解決済み'
    assert_text '未解決'
    assert_equal practice.questions.length, 11
  end

  test 'show common description on each page' do
    visit_with_auth "/practices/#{practices(:practice1).id}", 'hajime'
    assert_text '困った時は'
    visit "/practices/#{practices(:practice2).id}"
    assert_text '困った時は'
  end

  test 'not show common description block when practice_common_description is wip' do
    pages(:page10).update!(wip: true) # practice_common_description
    visit_with_auth "/practices/#{practices(:practice1).id}", 'hajime'
    assert_selector '.page-header__title', text: 'OS X Mountain Lionをクリーンインストールする'
    assert_no_selector '.common-page-body', text: '困った時は'
  end

  test 'not show common description block when practice_common_description does not exist' do
    pages(:page10).delete # practice_common_description
    visit_with_auth "/practices/#{practices(:practice1).id}", 'hajime'
    assert_selector '.page-header__title', text: 'OS X Mountain Lionをクリーンインストールする'
    assert_no_selector '.common-page-body', text: '困った時は'
  end

  test 'escape markdown, javascript, and html tags entered in the summary' do
    escape_text = <<~TEXT
      # マークダウン
      <script>alert('XSS')</script>
      <h1>HTMLタグ</h1>
    TEXT

    visit_with_auth edit_mentor_practice_path(practices(:practice1)), 'komagata'
    within 'form[name=practice]' do
      fill_in 'practice[summary]', with: escape_text.chop
      click_button '更新する'
    end

    assert_equal escape_text.chop, first('.card-body.is-practice').text
  end

  test 'add ogp image' do
    practice = practices(:practice1)
    visit_with_auth edit_mentor_practice_path(practice), 'komagata'
    within 'form[name=practice]' do
      attach_file 'practice[ogp_image]', 'test/fixtures/files/practices/ogp_images/1.jpg', make_visible: true
    end
    click_button '更新する'

    visit edit_mentor_practice_path(practice)
    within('form[name=practice]') do
      assert_selector 'label[for=practice_ogp_image] img[src$="1.jpg"]'
    end
  end

  test 'show both in the summary ( summary_text: yes / ogp_image: yes )' do
    practice = practices(:practice1)
    visit_with_auth edit_mentor_practice_path(practice), 'komagata'
    within 'form[name=practice]' do
      attach_file 'practice[ogp_image]', 'test/fixtures/files/practices/ogp_images/1.jpg', make_visible: true
      fill_in 'practice[summary]', with: '概要です'
    end
    click_button '更新する'

    within :css, '.a-card', text: '概要' do
      assert_selector 'img[src$="1.jpg"]'
      assert_selector 'p', text: '概要です'
    end
  end

  test 'show only text in the summary ( summary_text: yes / ogp_image: no )' do
    practice = practices(:practice1)
    visit_with_auth edit_mentor_practice_path(practice), 'komagata'
    within 'form[name=practice]' do
      fill_in 'practice[summary]', with: '概要です'
    end
    click_button '更新する'

    within :css, '.a-card', text: '概要' do
      assert_no_selector 'img'
      assert_selector 'p', text: '概要です'
    end
  end

  test 'not show the summary ( summary_text: no / ogp_image: no )' do
    practice = practices(:practice1)
    visit_with_auth practice_path(practice), 'komagata'

    assert_no_selector '.a-card', text: '概要'
  end

  test 'not show the summary ( summary_text: no / ogp_image: yes )' do
    practice = practices(:practice1)
    visit_with_auth edit_mentor_practice_path(practice), 'komagata'
    within 'form[name=practice]' do
      attach_file 'practice[ogp_image]', 'test/fixtures/files/practices/ogp_images/1.jpg', make_visible: true
    end
    click_button '更新する'

    assert_no_selector '.a-card', text: '概要'
  end
end
