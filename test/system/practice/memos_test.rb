# frozen_string_literal: true

require 'application_system_test_case'

class Practice::MemoTest < ApplicationSystemTestCase
  setup do
    @product = products(:product2)
    @practice = @product.practice
  end

  test 'edit, preview and save a memo' do
    open_memo
    click_button '編集'
    assert_field 'practice[memo]', with: @practice.memo

    memo = '**更新したメモ**'
    fill_in 'practice[memo]', with: memo
    find('[data-memo-editor-target="editorPreviewTab"]').click
    within '[data-memo-editor-target="editorPreviewContent"]' do
      assert_selector 'strong', text: '更新したメモ'
    end

    click_button '保存する'
    assert_text '保存しました！'
    assert_selector '[data-memo-editor-target="displayContent"] strong', text: '更新したメモ'
    assert_no_selector '[data-memo-editor-target="editor"]'
  end

  test 'cancel editing restores the last successfully saved memo' do
    open_memo
    click_button '編集'
    saved_memo = '保存したメモ'
    fill_in 'practice[memo]', with: saved_memo
    click_button '保存する'
    assert_memo_display saved_memo

    click_button '編集'
    assert_field 'practice[memo]', with: saved_memo
    fill_in 'practice[memo]', with: 'キャンセルする変更'
    click_button 'キャンセル'
    assert_memo_display saved_memo

    click_button '編集'
    assert_field 'practice[memo]', with: saved_memo
  end

  test 'keep the input after a failed save and retry successfully' do
    open_memo
    click_button '編集'
    memo = '失敗後に再保存するメモ'
    fill_in 'practice[memo]', with: memo

    page.driver.with_playwright_page do |playwright_page|
      playwright_page.route("**/api/practices/#{@practice.id}",
                            ->(route, _request) { route.fulfill(status: 422, body: '') }, times: 1)
    end

    click_button '保存する'
    assert_text 'メモの保存に失敗しました'
    assert_no_text '保存しました！'
    assert_field 'practice[memo]', with: memo, disabled: false

    click_button '保存する'
    assert_text '保存しました！'
    assert_memo_display memo
  end

  test 'show a message when the memo is initially empty' do
    @practice.update!(memo: '')
    open_memo

    assert_selector '[data-memo-editor-target="display"]', text: 'プラクティスメモはまだありません。'
  end

  test 'save an empty memo and show the empty message' do
    open_memo
    click_button '編集'
    assert_field 'practice[memo]', with: @practice.memo
    fill_in 'practice[memo]', with: ''
    click_button '保存する'

    assert_selector '[data-memo-editor-target="display"]', text: 'プラクティスメモはまだありません。'
  end

  private

  def open_memo
    visit_with_auth "/products/#{@product.id}", 'komagata'
    check 'toggle-mentor-memo-body', allow_label_click: true, visible: false
  end

  def assert_memo_display(memo)
    assert_selector '[data-memo-editor-target="displayContent"]', text: memo
  end
end
