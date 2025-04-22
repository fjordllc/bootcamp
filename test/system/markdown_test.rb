# frozen_string_literal: true

require 'application_system_test_case'

class MarkdownTest < ApplicationSystemTestCase
  test 'speak block test' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'インタビュー'
    fill_in 'page[body]', with: ":::speak @mentormentaro\n## 質問\nあああ\nいいい\n:::"

    click_button 'Docを公開'

    assert_css '.a-long-text.is-md.js-markdown-view'
    assert_css '.speak'
    assert_css "a[href='/users/mentormentaro']"
    emoji = find('.js-user-icon.a-user-emoji')
    assert_includes emoji['title'], '@mentormentaro'
    assert_includes emoji['data-user'], 'mentormentaro'
  end

  test 'user profile image markdown test' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'レポート'
    fill_in 'page[body]', with: ":@mentormentaro: \n すみません、これも確認していただけませんか？"

    click_button 'Docを公開'

    assert_css '.a-long-text.is-md.js-markdown-view'
    assert_css "a[href='/users/mentormentaro']"
    emoji = find('.js-user-icon.a-user-emoji')
    assert_includes emoji['title'], '@mentormentaro'
    assert_includes emoji['data-user'], 'mentormentaro'
  end

  test 'escapes and disables style tags' do
    visit_with_auth new_page_path, 'komagata'

    fill_in('page[title]', with: 'styleタグのテスト')
    fill_in('page[body]', with: '<style>p { color: red; }</style><p>これはテストです</p>')
  
    click_button 'Docを公開'
  
    assert_text '<style>p { color: red; }</style>'
  
    color = page.evaluate_script(<<~JS)
      getComputedStyle(document.querySelector('p')).color
    JS
    refute_equal 'rgb(255, 0, 0)', color
  end

  test 'escapes and disables onload attributes' do
    visit_with_auth new_page_path, 'komagata'
    fill_in('page[title]', with: 'onloadが発火しないことのテスト')
  
    fill_in('page[body]', with: '<iframe onload="document.body.appendChild(document.createElement(\'h3\'))"></iframe>')
  
    click_button 'Docを公開'
  
    assert_no_selector 'h3'
  
    assert_text '<iframe onload="document.body.appendChild(document.createElement(\'h3\'))"></iframe>'
  end

  # TODO: 動画機能が実装されたら削除する
  test 'should convert private vimeo url' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[body]', with: '(https://vimeo.com/0000000000/1aaaaaaaaa)'
    assert page.has_text?('(0000000000?h=1aaaaaaaaa)')
  end

  test 'create video tag by markdown syntax' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'markdown表記でvideoタグが作成されているかのテスト'
    fill_in 'page[body]', with: '!video(http://localhost:3000/rails/active_storage/blobs/redirect/test.mp4)'

    click_button 'Docを公開'

    assert page.has_css?('video')
    video_tag = page.find('video')
    assert video_tag[:controls]
    assert_equal video_tag[:src], 'http://localhost:3000/rails/active_storage/blobs/redirect/test.mp4'
  end

  def cmd_ctrl
    page.driver.browser.capabilities.platform_name.include?('mac') ? :command : :control
  end

  def all_copy(selector)
    find(selector).native.send_keys([cmd_ctrl, 'a'], [cmd_ctrl, 'c'])
  end

  # headless chromeでnavigator.clipboard.readText()を実行する時に必要
  # https://github.com/fjordllc/bootcamp/pull/6747#discussion_r1325417231
  # https://bootcamp.fjord.jp/reports/80292
  def grant_clipboard_read_permission
    cdp_permission = {
      origin: page.server_url,
      permission: { name: 'clipboard-read' },
      setting: 'granted'
    }
    page.driver.browser.execute_cdp('Browser.setPermission', **cdp_permission)
  end

  def read_clipboard_text
    page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
  end

  def paste(selector)
    find(selector).native.send_keys([cmd_ctrl, 'v'])
  end

  # CIでのみペースト前のctrl + Aが効かないため文字列の選択をselect()メソッドで実行
  # https://github.com/fjordllc/bootcamp/pull/6747#discussion_r1325419865
  # https://bootcamp.fjord.jp/questions/1720
  def select_text_and_paste(selector)
    page.execute_script("document.querySelector('#{selector}').select();")
    paste(selector)
  end

  def undo(selector)
    find(selector).native.send_keys([cmd_ctrl, 'z'])
  end

  test 'should automatically create Markdown link when pasting a URL text into selected text' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[title]', with: 'https://bootcamp.fjord.jp/')
    assert_field('report[title]', with: 'https://bootcamp.fjord.jp/')
    all_copy('#report_title')
    grant_clipboard_read_permission
    clip_text = read_clipboard_text
    assert_equal 'https://bootcamp.fjord.jp/', clip_text
    fill_in('report[description]', with: 'FBC')
    assert_field('report[description]', with: 'FBC')
    select_text_and_paste('#report_description')
    assert_field('report[description]', with: '[FBC](https://bootcamp.fjord.jp/)')
    undo('#report_description')
    assert_field('report[description]', with: 'FBC')
  end

  test 'should not create Markdown link when pasting non-URL text into selected text' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[title]', with: 'FBC')
    assert_field('report[title]', with: 'FBC')
    all_copy('#report_title')
    grant_clipboard_read_permission
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
    all_copy('#report_title')
    grant_clipboard_read_permission
    clip_text = read_clipboard_text
    assert_equal 'https://bootcamp.fjord.jp/', clip_text
    paste('#report_description')
    assert_field('report[description]', with: 'https://bootcamp.fjord.jp/')
  end

  test 'should escape square brackets in the selected text when pasting a URL text' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[title]', with: 'https://bootcamp.fjord.jp/')
    assert_field('report[title]', with: 'https://bootcamp.fjord.jp/')
    all_copy('#report_title')
    grant_clipboard_read_permission
    clip_text = read_clipboard_text
    assert_equal 'https://bootcamp.fjord.jp/', clip_text
    fill_in('report[description]', with: '[]')
    assert_field('report[description]', with: '[]')
    select_text_and_paste('#report_description')
    assert_field('report[description]', with: '[\[\]](https://bootcamp.fjord.jp/)')
  end

  test 'should expand link card' do
    visit_with_auth new_report_path, 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'リンクカードが展開される')
      fill_in('report[description]', with: '@[card](https://bootcamp.fjord.jp/)')
      fill_in('report[reported_on]', with: Time.current)

      check '学習時間は無し', allow_label_click: true
    end

    click_button '提出'
    assert_selector '.a-link-card'
    assert_no_selector 'a.before-replacement-link-card[href="https://bootcamp.fjord.jp/"]', visible: true
  end

  test 'should expand link card for tweet' do
    visit_with_auth new_report_path, 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'リンクカードが展開される')
      fill_in('report[description]', with: '@[card](https://x.com/fjordbootcamp/status/1866097842483503117)')
      fill_in('report[reported_on]', with: Time.current)

      check '学習時間は無し', allow_label_click: true
    end

    click_button '提出'
    assert_selector '.twitter-tweet'
    assert_no_selector 'a.before-replacement-link-card[href="https://x.com/fjordbootcamp/status/1866097842483503117"]', visible: true
  end
end
