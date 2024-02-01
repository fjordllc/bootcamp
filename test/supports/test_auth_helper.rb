# frozen_string_literal: true

module TestAuthHelper
  # 認証のためのリクエストがテストの実行時間でかなりの部分を占めているため、高速にテスト時の認証を行うためのメソッド
  def visit_with_auth(url, login_name)
    uri = URI.parse(url)
    queries = Rack::Utils.parse_nested_query(uri.query)
    queries['_login_name'] = login_name
    uri.query = queries.to_query
    visit uri.to_s
  end

  # 特定のテストが落ちてしまうことを回避するため、明示的にログアウトを行うメソッド
  # 詳しくは Issue#7168 参照
  def logout_by_menu
    find('.test-show-menu').click
    click_link 'ログアウト'
    assert_text 'ログアウトしました。'
  end
end
