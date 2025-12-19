# frozen_string_literal: true

require 'application_system_test_case'

module Practices
  class SummaryTest < ApplicationSystemTestCase
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

      assert_text 'プラクティスを更新しました。'
      assert_no_selector '.a-card', text: '概要'
    end
  end
end
