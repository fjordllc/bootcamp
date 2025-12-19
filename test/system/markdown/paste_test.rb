# frozen_string_literal: true

require 'application_system_test_case'

module Markdown
  class PasteTest < ApplicationSystemTestCase
    test 'should automatically create Markdown link when pasting a URL text into selected text' do
      visit_with_auth new_report_path, 'komagata'
      fill_in('report[title]', with: 'https://bootcamp.fjord.jp/')
      assert_field('report[title]', with: 'https://bootcamp.fjord.jp/')
      select_all_and_copy('#report_title')
      grant_clipboard_permission
      clip_text = read_clipboard_text
      assert_equal 'https://bootcamp.fjord.jp/', clip_text
      fill_in('report[description]', with: 'FBC')
      assert_field('report[description]', with: 'FBC')
      select_text_and_paste('#report_description')
      assert_field('report[description]', with: '[FBC](https://bootcamp.fjord.jp/)')
      undo_in('#report_description')
      assert_field('report[description]', with: 'FBC')
    end

    test 'should not create Markdown link when pasting non-URL text into selected text' do
      visit_with_auth new_report_path, 'komagata'
      fill_in('report[title]', with: 'FBC')
      assert_field('report[title]', with: 'FBC')
      select_all_and_copy('#report_title')
      grant_clipboard_permission
      clip_text = read_clipboard_text
      assert_equal 'FBC', clip_text
      fill_in('report[description]', with: 'test')
      assert_field('report[description]', with: 'test')
      select_text_and_paste('#report_description')
      assert_field('report[description]', with: 'FBC')
    end

    test 'should not create Markdown link when pasting a URL text without text selection' do
      visit_with_auth new_report_path, 'komagata'
      fill_in('report[title]', with: 'https://bootcamp.fjord.jp/')
      assert_field('report[title]', with: 'https://bootcamp.fjord.jp/')
      select_all_and_copy('#report_title')
      grant_clipboard_permission
      clip_text = read_clipboard_text
      assert_equal 'https://bootcamp.fjord.jp/', clip_text
      paste_to('#report_description')
      assert_field('report[description]', with: 'https://bootcamp.fjord.jp/')
    end

    test 'should escape square brackets in the selected text when pasting a URL text' do
      visit_with_auth new_report_path, 'komagata'
      fill_in('report[title]', with: 'https://bootcamp.fjord.jp/')
      assert_field('report[title]', with: 'https://bootcamp.fjord.jp/')
      select_all_and_copy('#report_title')
      grant_clipboard_permission
      clip_text = read_clipboard_text
      assert_equal 'https://bootcamp.fjord.jp/', clip_text
      fill_in('report[description]', with: '[]')
      assert_field('report[description]', with: '[]')
      select_text_and_paste('#report_description')
      assert_field('report[description]', with: '[\[\]](https://bootcamp.fjord.jp/)')
    end
  end
end
