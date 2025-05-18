# frozen_string_literal: true

require 'application_system_test_case'

class PairWorksTest < ApplicationSystemTestCase
  test 'show listing unsolved pair works' do
    visit_with_auth pair_works_path(target: 'not_solved'), 'kimura'
    assert_equal '募集中のペアワーク | FBC', title
  end

  test 'show listing solved pair works' do
    visit_with_auth pair_works_path(target: 'solved'), 'kimura'
    assert_equal 'ペア確定済みのペアワーク | FBC', title
  end

  test 'show listing all pair works' do
    visit_with_auth pair_works_path, 'kimura'
    assert_equal '全てのペアワーク | FBC', title
  end

  test 'create a pair_work' do
    travel_to Time.zone.local(2025, 3, 2, 0, 0, 0) do
      visit_with_auth new_pair_work_path, 'kimura'
      within 'form[name=pair_work]' do
        within '.select-practices' do
          find('.choices__inner').click
          find('#choices--js-choices-practice-item-choice-12', text: 'sshdでパスワード認証を禁止にする').click
        end
        fill_in 'pair_work[title]', with: 'テストのペアワーク募集'
        fill_in 'pair_work[description]', with: 'テストのペアワーク募集です。'
        within '.form-table' do
          check 'schedule_ids_2025-03-03 00:00:00 +0900', allow_label_click: true
        end
        click_button '登録する'
      end
      assert_text 'ペアワークを作成しました。'
      assert_selector '.a-title-label.is-solved.is-danger', text: '募集中'
      assert_text 'Watch中'

      visit_with_auth pair_works_path(target: 'not_solved'), 'mentormentaro'
      click_on 'テストのペアワーク募集'
      assert_text 'Watch中'
    end
  end

  test 'create a pair_work matching' do
    travel_to Time.zone.local(2025, 1, 1, 0, 0, 0) do
      pair_work = pair_works(:pair_work1)
      visit_with_auth pair_work_path(pair_work), 'komagata'
      within '.a-table' do
        accept_alert do
          find_button(class: '2025-01-02 01:00:00 +0900').click
        end
      end
      assert_selector '.a-title-label.is-solved.is-success', text: 'ペア確定'
      within 'header.event-main-actions__header' do
        assert_text 'ペアが確定しました'
        assert_selector 'a', text: 'カレンダーに登録'
      end
      within '.event-main-actions__body' do
        assert_selector "img[title*='komagata']"
        assert_selector 'a', text: 'komagata (コマガタ マサキ)'
        assert_text '2025年01月02日(木) 01:00'
        assert_text 'ペアワーク・モブワーク1'
      end
    end
  end

  test 'update a pair_work' do
    pair_work = pair_works(:pair_work1)
    visit_with_auth pair_work_path(pair_work), 'kimura'
    click_link '内容修正'
    fill_in 'pair_work[title]', with: 'ペアワークのテスト（修正）'
    fill_in 'pair_work[description]', with: 'ペアワークのテストです。（修正）'
    within '.select-practices' do
      find('.choices__inner').click
      find('#choices--js-choices-practice-item-choice-12', text: 'sshdでパスワード認証を禁止にする').click
    end
    click_button '更新する'

    assert_text 'ペアワークを更新しました。'
    assert_text 'ペアワークのテスト（修正）'
    assert_text 'ペアワークのテストです。（修正）'
    assert_selector 'a.a-category-link', text: 'sshdでパスワード認証を禁止にする'
  end

  test 'delete a pair_work' do
    pair_work = pair_works(:pair_work1)
    visit_with_auth pair_work_path(pair_work), 'kimura'
    accept_confirm do
      click_link '削除'
    end

    assert_text 'ペアワークを削除しました。'
    assert_equal '全てのペアワーク | FBC', title
  end

  test 'only authorized users can update and delete pair_works' do
    pair_work = pair_works(:pair_work1)
    pair_work_user = 'kimura'
    admin_user = 'komagata'
    user = 'hatsuno'

    visit_with_auth pair_work_path(pair_work), pair_work_user
    assert_text '内容修正'
    assert_text '削除'

    visit_with_auth pair_work_path(pair_work), admin_user
    assert_text '内容修正'
    assert_text '削除'

    visit_with_auth pair_work_path(pair_work), user
    assert_no_text '内容修正'
    assert_no_text '削除'
  end

  test 'notify to chat after publish a pair_work' do
    travel_to Time.zone.local(2025, 3, 2, 0, 0, 0) do
      visit_with_auth new_pair_work_path, 'kimura'
      within 'form[name=pair_work]' do
        fill_in 'pair_work[title]', with: 'テストのペアワーク募集'
        fill_in 'pair_work[description]', with: 'テストのペアワーク募集です。'
        within '.form-table' do
          check 'schedule_ids_2025-03-03 00:00:00 +0900', allow_label_click: true
        end
      end
      mock_log = []
      stub_info = proc { |i| mock_log << i }

      Rails.logger.stub(:info, stub_info) do
        click_button '登録する'
      end
      assert_text 'ペアワークを作成しました。'
      assert_match 'Message to Discord.', mock_log.to_s
    end
  end
end
