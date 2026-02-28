# frozen_string_literal: true

require 'test_helper'

class API::NotificationsDetailTest < ActionDispatch::IntegrationTest
  fixtures :users, :notifications

  test 'unread notifications response has all required fields with correct types' do
    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(status: 'unread', format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    assert json.key?('notifications'), 'トップレベルにnotificationsキーがない'
    assert json.key?('total_pages'), 'トップレベルにtotal_pagesキーがない'
    assert_kind_of Array, json['notifications']
    assert_kind_of Integer, json['total_pages']
    assert json['total_pages'].positive?, 'total_pagesは1以上であること'
    assert json['notifications'].size.positive?, '未読通知が1件以上あること'

    json['notifications'].each_with_index do |n, i|
      ctx = "通知##{i} (id=#{n['id']})"

      # 必須フィールドの型チェック
      assert_kind_of Integer, n['id'], "#{ctx}: idはIntegerであること"
      assert_kind_of String, n['kind'], "#{ctx}: kindはStringであること"
      assert_includes Notification.kinds.keys, n['kind'], "#{ctx}: kind '#{n['kind']}'は有効なenum値でない"
      assert_kind_of String, n['message'], "#{ctx}: messageはStringであること"
      assert n['message'].present?, "#{ctx}: messageは空でないこと"
      assert_kind_of String, n['path'], "#{ctx}: pathはStringであること"
      assert n['path'].start_with?('/'), "#{ctx}: pathは/で始まること"
      assert_not n['read'], "#{ctx}: 未読通知のreadはfalseであること"
      assert_kind_of String, n['created_at'], "#{ctx}: created_atはStringであること"
      assert_nothing_raised { Time.zone.parse(n['created_at']) }

      # 送信者の検証
      sender = n['sender']
      assert sender.present?, "#{ctx}: senderがnilでないこと"
      sender_ctx = "#{ctx} 送信者(#{sender['login_name']})"

      assert_kind_of Integer, sender['id'], "#{sender_ctx}: idはIntegerであること"
      assert_kind_of String, sender['login_name'], "#{sender_ctx}: login_nameはStringであること"
      assert sender['login_name'].present?, "#{sender_ctx}: login_nameは空でないこと"
      assert_match(/\A[a-zA-Z0-9_-]+\z/, sender['login_name'], "#{sender_ctx}: login_nameに不正な文字が含まれている")
      assert_kind_of String, sender['avatar_url'], "#{sender_ctx}: avatar_urlはStringであること"
      assert sender['avatar_url'].present?, "#{sender_ctx}: avatar_urlは空でないこと"
      assert sender.key?('company'), "#{sender_ctx}: companyキーが存在すること"

      # 企業情報の検証（nullの場合もあるが、存在する場合は構造が正しいこと）
      company = sender['company']
      if company.present?
        assert company.key?('logo_url'), "#{sender_ctx}: companyにlogo_urlがあること"
        assert company.key?('url'), "#{sender_ctx}: companyにurlがあること"
        assert_kind_of String, company['url'], "#{sender_ctx}: company urlはStringであること"
      end

      # 送信者が実在するユーザーであること
      user = User.find_by(id: sender['id'])
      assert user.present?, "#{sender_ctx}: sender id #{sender['id']}がDBに存在しない"
      assert_equal user.login_name, sender['login_name'], "#{sender_ctx}: login_nameがDBと一致しない"
    end
  end

  test 'all notifications response is valid with correct order' do
    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    notifications = json['notifications']
    assert_kind_of Array, notifications
    assert notifications.size.positive?, '通知が1件以上あること'

    # 新しい順にソートされていること
    timestamps = notifications.map { |n| Time.zone.parse(n['created_at']) }
    assert_equal timestamps, timestamps.sort.reverse, '通知は新しい順にソートされていること'

    # 全通知にsenderデータが含まれていること
    notifications.each_with_index do |n, i|
      assert n['sender'].present?, "通知##{i}: senderがない"
      assert n['sender']['login_name'].present?, "通知##{i}: senderのlogin_nameがない"
      assert n['sender']['avatar_url'].present?, "通知##{i}: senderのavatar_urlがない"
    end
  end

  test 'target filter returns only matching kinds' do
    token = create_token('hatsuno', 'testtest')

    Notification::TARGETS_TO_KINDS.each do |target, expected_kinds|
      get api_notifications_path(target:, format: :json),
          headers: { 'Authorization' => "Bearer #{token}" }
      assert_response :ok

      json = JSON.parse(response.body)
      json['notifications'].each do |n|
        assert_includes expected_kinds.map(&:to_s), n['kind'],
                        "target=#{target}で予期しないkind '#{n['kind']}'が返された"
      end
    end
  end

  test 'pagination returns correct pages without overlap' do
    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(page: 1, per: 5, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    assert json['notifications'].size <= 5, 'per指定のページサイズを超えないこと'
    assert json['total_pages'].positive?

    # 2ページ目も取得できること
    get api_notifications_path(page: 2, per: 5, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    json2 = JSON.parse(response.body)
    assert_kind_of Array, json2['notifications']

    # 1ページ目と2ページ目の通知が重複しないこと
    if json['notifications'].size == 5 && json2['notifications'].size.positive?
      ids1 = json['notifications'].map { |n| n['id'] }
      ids2 = json2['notifications'].map { |n| n['id'] }
      assert_empty ids1 & ids2, '1ページ目と2ページ目の通知が重複しないこと'
    end
  end

  test 'sender with company has logo_url and url' do
    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(status: 'unread', format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    with_company = json['notifications'].select { |n| n['sender']['company'].present? }
    assert with_company.size.positive?, '企業所属の送信者からの通知が1件以上あること'

    with_company.each do |n|
      company = n['sender']['company']
      sender_name = n['sender']['login_name']
      assert company['logo_url'].present?, "#{sender_name}の企業にlogo_urlがあること"
      assert company['url'].present?, "#{sender_name}の企業にurlがあること"
      assert_includes company['url'], '/companies/', "#{sender_name}の企業urlが企業パスであること"
    end
  end

  test 'sender without company has null company' do
    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    without_company = json['notifications'].select { |n| n['sender']['company'].blank? }

    # companyキー自体は存在し、値がnull/空であることを確認
    without_company.each do |n|
      assert n['sender'].key?('company'), "#{n['sender']['login_name']}のsenderにcompanyキーが存在すること"
    end
  end

  test 'unauthorized access returns 401' do
    get api_notifications_path(format: :json)
    assert_response :unauthorized

    get api_notifications_path(status: 'unread', format: :json)
    assert_response :unauthorized
  end
end
