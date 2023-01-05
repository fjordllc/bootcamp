# frozen_string_literal: true

module LoginAssertHelper
  def assert_login_required(path)
    visit path
    assert_text 'ログインしてください'
    assert_selector 'h3', text: 'フィヨルドブートキャンプとは？'
  end

  def assert_no_login_required(path, text)
    visit path
    assert_text text
    assert_no_text 'ログインしてください'
  end
end
