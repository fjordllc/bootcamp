# frozen_string_literal: true

require 'application_system_test_case'

module Practices
  class MentorTest < ApplicationSystemTestCase
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
        fill_in 'practice_product_template_attributes_description', with: 'テストテンプレート'
        uncheck 'practice[pjord_review]', allow_label_click: true
        click_button '登録する'
      end
      assert_text 'プラクティスを作成しました'
      assert_not_predicate Practice.order(:created_at).last, :pjord_review?
    end

    test 'can create practice without product template' do
      visit_with_auth '/mentor/practices/new', 'komagata'

      within 'form[name=practice]' do
        fill_in 'practice[title]', with: 'テンプレなし'
        check categories(:category1).name, allow_label_click: true
        fill_in 'practice[description]', with: 'テストの内容です'
        fill_in 'practice[goal]', with: 'テストのゴールの内容です'
        click_button '登録する'
      end

      assert_text 'プラクティスを作成しました'

      practice = Practice.find_by!(title: 'テンプレなし')
      visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
      assert_empty find_field('practice_product_template_attributes_description').value
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
        fill_in 'practice_product_template_attributes_description', with: 'テストテンプレート'
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
        fill_in 'practice_product_template_attributes_description', with: 'テストテンプレート'
        within '#reference_books' do
          click_link '書籍を選択'
        end
        click_button '更新する'
      end
      assert_text 'プラクティスを更新しました'
      visit "/products/#{product.id}"
      check 'toggle-mentor-memo-body', allow_label_click: true, visible: false
      assert_text 'メンター向けのメモの内容です'

      visit new_product_path(practice_id: practice.id)
      assert_field 'product[body]', with: 'テストテンプレート'
    end

    test 'update product template' do
      practice = practices(:practice1)
      visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
      assert_field 'practice_product_template_attributes_description', with: '更新前テンプレート'
      fill_in 'practice_product_template_attributes_description', with: '更新後テンプレート'
      click_button '更新する'
      assert_text 'プラクティスを更新しました'

      visit new_product_path(practice_id: practice.id)
      assert_field 'product[body]', with: '更新後テンプレート'
    end

    test 'add a book' do
      practice = practices(:practice2)
      book = books(:book1)
      visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
      within '#reference_books' do
        click_link '書籍を選択'
        within first('.choices') do
          find('.choices__inner').click
          find('.choices__item--choice', text: book.title).click
        end
      end
      click_button '更新する'
      assert_text 'プラクティスを更新しました。'
      assert_text book.title
    end

    test 'update a book' do
      practice = practices(:practice1)
      book = books(:book2)
      visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
      within '#reference_books' do
        within first('.choices') do
          find('.choices__inner').click
          find('.choices__item--choice', text: book.title).click
        end
      end
      click_button '更新する'
      assert_text 'プラクティスを更新しました。'
      assert_text book.title
    end

    test 'add completion image' do
      practice = practices(:practice1)
      visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'

      assert_selector 'form'
      attach_file 'practice[completion_image]', 'test/fixtures/files/practices/ogp_images/1.jpg', make_visible: true
      click_button '更新する'
      assert_text 'プラクティスを更新しました。'

      visit_with_auth "/mentor/practices/#{practice.id}/edit", 'komagata'
      assert_selector 'form[name=practice]'
      assert_selector 'img'
    end

    test 'show setting for completed percentage' do
      visit_with_auth '/mentor/practices/new', 'komagata'
      assert_text '進捗の計算'
    end

    test 'update practice in the role of mentor' do
      practice = practices(:practice2)
      visit_with_auth "/mentor/practices/#{practice.id}/edit", 'mentormentaro'
      within 'form[name=practice]' do
        fill_in 'practice[title]', with: 'テストプラクティス'
        within '#reference_books' do
          click_link '書籍を選択'
        end
      end
      click_button '更新する'
      assert_text 'プラクティスを更新しました'
      visit "/practices/#{practice.id}"
      assert_equal 'プラクティス テストプラクティス | FBC', title
    end

    test 'show/hide memo for mentor' do
      practice = practices(:practice2)
      visit_with_auth "/practices/#{practice.id}", 'komagata'
      assert_text 'メンター向けメモ'
      page.execute_script("document.querySelector('#checkbox-mentor-mode').click()")
      assert_no_text 'メンター向けメモ'
    end

    test 'show/hide menu for mentor' do
      practice = practices(:practice2)
      visit_with_auth "/practices/#{practice.id}", 'komagata'
      assert_text '管理者・メンター用メニュー'
      page.execute_script("document.querySelector('#checkbox-mentor-mode').click()")
      assert_no_text '管理者・メンター用メニュー'
    end
  end
end
