# frozen_string_literal: true

module LoginAssertHelper
  def assert_login_required(path)
    visit path
    assert_text 'ログインしてください'
    assert_selector 'h1', text: 'プラス戦力のスキルを身につける'
  end

  def assert_no_login_required(path, text, check_path: true)
    visit path
    assert_text text, wait: 10
    assert_no_text 'ログインしてください'
    if check_path
      current_path = URI.parse(current_url).path
      assert_equal path, current_path, "Expected path #{path} but got #{current_path}"
    end
  end
end
