# frozen_string_literal: true

module ClipboardHelper
  def grant_clipboard_permission
    page.driver.browser.execute_cdp(
      'Browser.grantPermissions',
      origin: page.server_url,
      permissions: %w[clipboardReadWrite clipboardSanitizedWrite]
    )
  rescue StandardError => e
    warn "Browser.grantPermissions failed: #{e.message}, trying fallback method"
    cdp_permission = {
      origin: page.server_url,
      permission: { name: 'clipboard-read' },
      setting: 'granted'
    }
    page.driver.browser.execute_cdp('Browser.setPermission', **cdp_permission)
  end

  def clipboard_supported?
    page.evaluate_script('typeof navigator.clipboard !== "undefined"')
  end

  def read_clipboard_with_retry(expected_text: nil, max_retries: 20, interval: 0.5)
    max_retries.times do
      clip_text = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
      return clip_text if expected_text.nil? || clip_text == expected_text

      sleep interval
    end

    page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
  end

  def click_and_verify_clipboard_copy(selector, expected_url, use_first: false)
    if use_first
      first(selector).click
    else
      find(selector).click
    end

    grant_clipboard_permission

    using_wait_time 15 do
      clip_text = read_clipboard_with_retry(expected_text: expected_url, max_retries: 20, interval: 0.5)
      assert_equal expected_url, clip_text
    end
  end
end
