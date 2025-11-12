# frozen_string_literal: true

module ClipboardHelper
  # クリップボード権限を付与
  def grant_clipboard_permission
    # Browser.grantPermissions CDPコマンドで権限を付与
    page.driver.browser.execute_cdp(
      'Browser.grantPermissions',
      origin: page.server_url,
      permissions: %w[clipboardReadWrite clipboardSanitizedWrite]
    )
  rescue StandardError => e
    # フォールバック: 古い方法も試す
    warn "Browser.grantPermissions failed: #{e.message}, trying fallback method"
    cdp_permission = {
      origin: page.server_url,
      permission: { name: 'clipboard-read' },
      setting: 'granted'
    }
    page.driver.browser.execute_cdp('Browser.setPermission', **cdp_permission)
  end

  # クリップボードAPIがサポートされているか確認
  def clipboard_supported?
    page.evaluate_script('typeof navigator.clipboard !== "undefined"')
  end

  # リトライ付きでクリップボードの内容を読み取る
  def read_clipboard_with_retry(expected_text: nil, max_retries: 20, interval: 0.5)
    max_retries.times do
      clip_text = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
      return clip_text if expected_text.nil? || clip_text == expected_text

      sleep interval
    end

    # 最後にもう一度読み取って返す
    page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
  end

  # 要素をクリックしてクリップボードにコピーされることを検証
  def click_and_verify_clipboard_copy(selector, expected_url, use_first: false)
    # 要素をクリック
    if use_first
      first(selector).click
    else
      find(selector).click
    end

    # JavaScriptのクリック処理が実行されるまで待機
    sleep 1

    # クリップボード権限を付与
    grant_clipboard_permission

    # 権限付与後の処理完了を待機
    sleep 0.5

    # クリップボードの内容を検証
    using_wait_time 15 do
      clip_text = read_clipboard_with_retry(expected_text: expected_url, max_retries: 20, interval: 0.5)
      assert_equal expected_url, clip_text
    end
  end
end
