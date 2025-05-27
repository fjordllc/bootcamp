# frozen_string_literal: true

require 'application_system_test_case'

class MarkdownTest < ApplicationSystemTestCase
  ALL_TAGS = %w[
  a abbr acronym address applet area article aside audio b base basefont bdi bdo
  big blockquote body br button canvas caption center cite code col colgroup
  data datalist dd del details dfn dialog dir div dl dt em embed fieldset figcaption
  figure font footer form frame frameset h1 h2 h3 h4 h5 h6 head header hr html i
  iframe img input ins isindex kbd label legend li link listing main map mark marquee
  menu menuitem meta meter nav noframes noscript object ol optgroup option output
  p param picture plaintext pre progress q rb rp rt rtc ruby s samp script section
  select slot small source span strike strong style sub summary sup table tbody td
  template textarea tfoot th thead time title tr track tt u ul var video wbr xmp
]

ALLOWED_TAGS = %w[
  a abbr address article aside b bdi bdo blockquote br cite code dd del details dfn div dl dt em figcaption figure footer h1 h2 h3 h4 h5 h6 header hr i img ins kbd li mark nav ol p pre q rp rt ruby s samp section small span strong sub summary sup time u ul video
]

ALLOWED_TABLE_TAGS = %w[table caption colgroup col thead tbody tfoot tr th td]

ALL_ATTRIBUTES = %w[
  accept accept-charset accesskey action align allow allowfullscreen allowpaymentrequest alt
  async autocapitalize autocomplete autofocus autoplay background bgcolor border
  buffered capture challenge charset checked cite class code codebase color cols colspan
  content contenteditable contextmenu controls coords crossorigin csp data datetime
  decoding default defer dir dirname disabled download draggable dropzone enctype enterkeyhint
  for form formaction formenctype formmethod formnovalidate formtarget headers height hidden
  high href hreflang http-equiv icon id importance inputmode integrity ismap itemprop keytype
  kind label lang language list loading loop low manifest max maxlength media method min
  minlength multiple muted name novalidate open optimum pattern ping placeholder playsinline
  poster preload readonly referrerpolicy rel required reversed rows rowspan sandbox scope
  scoped selected shape size sizes slot span spellcheck src srcdoc srclang srcset start step
  style summary tabindex target title translate type usemap value width wrap
  onabort onafterprint onbeforeprint onbeforeunload onblur oncanplay oncanplaythrough onchange
  onclick oncontextmenu oncopy oncuechange oncut ondblclick ondrag ondragend ondragenter
  ondragleave ondragover ondragstart ondrop ondurationchange onemptied onended onerror
  onfocus onhashchange oninput oninvalid onkeydown onkeypress onkeyup onload onloadeddata
  onloadedmetadata onloadstart onmessage onmousedown onmouseenter onmouseleave onmousemove
  onmouseout onmouseover onmouseup onmousewheel onoffline ononline onpagehide onpageshow
  onpaste onpause onplay onplaying onpopstate onprogress onratechange onreset onresize
  onscroll onsearch onseeked onseeking onselect onshow onstalled onstorage onsubmit onsuspend
  ontimeupdate ontoggle onunload onvolumechange onwaiting onwheel
]

ALLOWED_ATTRIBUTES = %w[
  href src alt title target rel width height class decoding loading style
]

  test 'keeps allowed tags' do
    visit_with_auth new_page_path, 'komagata'

    allowed_tag_string = ALLOWED_TAGS.map { |tag| "<#{tag}>OK</#{tag}>" }.join(' ')

    fill_in 'page[title]', with: 'Allowed Tags Simple Test'
    fill_in 'page[body]', with: allowed_tag_string

    click_button 'Docを公開'

    within '.a-long-text.is-md.js-markdown-view' do
      ALLOWED_TAGS.each do |tag|
        assert_selector tag, visible: :all
      end
    end
  end

  test 'strips forbidden tags' do
    forbidden_tags = ALL_TAGS - ALLOWED_TAGS - ALLOWED_TABLE_TAGS

    forbidden_tag_string = forbidden_tags.map { |tag| "<#{tag}>NG</#{tag}>" }.join(' ')

    visit_with_auth new_page_path, 'komagata'

    fill_in 'page[title]', with: 'XSS Test'
    fill_in 'page[body]', with: forbidden_tag_string

    click_button 'Docを公開'

    within '.a-long-text.is-md.js-markdown-view' do
      forbidden_tags.each do |tag|
        assert_no_selector tag
      end
    end
  end

  test 'keeps allowed table tags' do # テーブルタグは構造が正しくないと無効化されるので、個別でテストを用意
    table_html = <<~HTML
    <table>
      <caption>テーブルキャプション</caption>
      <colgroup>
        <col>
      </colgroup>
      <thead>
        <tr>
          <th>ヘッダ</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>データ</td>
        </tr>
      </tbody>
      <tfoot>
        <tr>
          <td>フッタ</td>
        </tr>
      </tfoot>
    </table>
  HTML

    visit_with_auth new_page_path, 'komagata'
  
    fill_in 'page[title]', with: 'Table Structure Test'
    fill_in 'page[body]', with: table_html
    click_button 'Docを公開'
  
    within '.a-long-text.is-md.js-markdown-view' do
      ALLOWED_TABLE_TAGS.each do |tag|
        assert_selector tag
      end
    end
  end

  test 'keeps allowed attributes' do
    visit_with_auth new_page_path, 'komagata'
  
    allowed_attrs_string = ALLOWED_ATTRIBUTES.map { |attr| "#{attr}=\"test\"" }.join(' ')
    body = "<span #{allowed_attrs_string}>テスト</span>"
  
    fill_in 'page[title]', with: 'Attributes Sanitization Test'
    fill_in 'page[body]', with: body
    click_button 'Docを公開'

    within '.a-long-text.is-md.js-markdown-view' do
      ALLOWED_ATTRIBUTES.each do |attr|
        assert_selector("span[#{attr}]")
      end
    end
  end

  test 'strips forbidden attributes' do
    visit_with_auth new_page_path, 'komagata'

    forbidden_attrs = ALL_ATTRIBUTES - ALLOWED_ATTRIBUTES
    forbidden_attrs_string = forbidden_attrs.map { |attr| "#{attr}=\"test\"" }.join(' ')
    body = "<span #{forbidden_attrs_string}>テスト</span>"
  
    fill_in 'page[title]', with: 'Attributes Sanitization Test'
    fill_in 'page[body]', with: body
    click_button 'Docを公開'

    within '.a-long-text.is-md.js-markdown-view' do
      forbidden_attrs.each do |attr|
        assert_no_selector("span[#{attr}]")
      end
    end
  end

  test 'speak block test' do
    reset_avatar(users(:mentormentaro))
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
    reset_avatar(users(:mentormentaro))
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

  test 'speak block with arguments test' do
    visit_with_auth new_page_path, 'machida'
    fill_in 'page[title]', with: 'インタビュー'
    fill_in 'page[body]', with: ":::speak(machida, https://avatars.githubusercontent.com/u/168265?v=4)\n## (名前, 画像URL)ver\n:::"

    click_button 'Docを公開'

    assert_css '.a-long-text.is-md.js-markdown-view'
    assert_css '.speak'
    assert_no_css "a[href='/users/machida']"

    img = find('.speak__speaker img')
    assert_includes img['src'], 'https://avatars.githubusercontent.com/u/168265?v=4'
    assert_includes img['title'], 'machida'

    name_span = find('.speak__speaker-name')
    assert_includes name_span.text, 'machida'
  end

  test 'speak block without @ test' do
    visit_with_auth new_page_path, 'machida'
    fill_in 'page[title]', with: 'インタビュー'
    fill_in 'page[body]', with: ":::speak username\n## 名前のみver\n:::"

    click_button 'Docを公開'

    assert_css '.a-long-text.is-md.js-markdown-view'
    assert_css '.speak'
    assert_no_css "a[href='/users/username']"

    img = find('.speak__speaker img')
    assert_includes img['src'], '/images/users/avatars/default.png'
    assert_includes img['title'], 'username'
  end
end
