# frozen_string_literal: true

require 'test_helper'

class SmartSearch::GoogleCloudCredentialsTest < ActiveSupport::TestCase
  def setup
    @original_env = ENV.to_h
  end

  def teardown
    ENV.clear
    ENV.update(@original_env)
  end

  test 'setup_credentials! with base64 environment variable' do
    # テスト用のダミーJSON認証情報
    dummy_credentials = {
      'type' => 'service_account',
      'project_id' => 'test-project',
      'private_key_id' => 'key123',
      'private_key' => '-----BEGIN PRIVATE KEY-----\ntest\n-----END PRIVATE KEY-----\n',
      'client_email' => 'test@test-project.iam.gserviceaccount.com',
      'client_id' => '123456789',
      'auth_uri' => 'https://accounts.google.com/o/oauth2/auth',
      'token_uri' => 'https://oauth2.googleapis.com/token'
    }.to_json

    base64_credentials = Base64.encode64(dummy_credentials)

    ENV['GOOGLE_CLOUD_CREDENTIALS_BASE64'] = base64_credentials
    ENV['GOOGLE_CLOUD_PROJECT'] = 'test-project'

    SmartSearch::GoogleCloudCredentials.setup_credentials!

    # GOOGLE_CREDENTIALS環境変数にデコードされたJSONが設定されていることを確認
    assert ENV['GOOGLE_CREDENTIALS'].present?
    parsed_content = JSON.parse(ENV['GOOGLE_CREDENTIALS'])
    assert_equal 'test-project', parsed_content['project_id']
  end

  test 'project_id returns from environment variable' do
    ENV['GOOGLE_CLOUD_PROJECT'] = 'env-project'

    assert_equal 'env-project', SmartSearch::GoogleCloudCredentials.project_id
  end

  test 'setup_credentials! skips when GOOGLE_APPLICATION_CREDENTIALS exists' do
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = __FILE__ # 存在するファイルを指定
    ENV['GOOGLE_CLOUD_CREDENTIALS_BASE64'] = 'should-not-be-used'

    original_path = ENV['GOOGLE_APPLICATION_CREDENTIALS']
    original_creds = ENV['GOOGLE_CREDENTIALS']
    
    SmartSearch::GoogleCloudCredentials.setup_credentials!

    # 既存の設定が変更されていないことを確認
    assert_equal original_path, ENV['GOOGLE_APPLICATION_CREDENTIALS']
    assert_equal original_creds, ENV['GOOGLE_CREDENTIALS']
  end

  test 'setup_credentials! skips when GOOGLE_CREDENTIALS exists' do
    original_creds = '{"type":"service_account"}'
    ENV['GOOGLE_CREDENTIALS'] = original_creds
    ENV['GOOGLE_CLOUD_CREDENTIALS_BASE64'] = 'should-not-be-used'

    SmartSearch::GoogleCloudCredentials.setup_credentials!

    # GOOGLE_CREDENTIALSが変更されていないことを確認
    assert_equal original_creds, ENV['GOOGLE_CREDENTIALS']
  end
end
