# frozen_string_literal: true

require 'application_system_test_case'

class Oauth2ProviderTest < ApplicationSystemTestCase
  setup do
    visit_with_auth root_path, 'komagata'
    Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'https://example.com/callback',
      scopes: 'read'
    )
  end

  test 'admin can access oauth2 provider page' do
    visit oauth_applications_path
    assert_equal 'Oauth2 Provider', title
  end

  test 'admin other than admin cannot access oauth2 provider page' do
    visit_with_auth root_path, 'kimura'
    visit oauth_applications_path
    assert_text '管理者としてログインしてください'
  end

  test 'add an application' do
    visit new_oauth_application_path
    within('form[class="new_doorkeeper_application"]') do
      fill_in 'Name', with: 'Sample Application'
      fill_in 'Redirect URL', with: 'https://example.com/callback'
      fill_in 'Scopes', with: 'read'
    end
    click_on '登録する'
    assert_text 'アプリケーションを追加しました。'
  end

  test 'edit an application' do
    visit "/oauth/applications/#{Doorkeeper::Application.last.id}/edit"
    within('form[class="edit_doorkeeper_application"]') do
      fill_in 'Name', with: 'Sample Application edited'
      fill_in 'Redirect URL', with: 'https://example.com/callback/edited'
    end
    click_on '登録する'
    assert_text 'アプリケーションを更新しました。'
  end

  test 'delete an application' do
    visit "/oauth/applications/#{Doorkeeper::Application.last.id}"
    click_on '削除'
    page.driver.browser.switch_to.alert.accept
    assert_text 'アプリケーションを削除しました。'
  end

  test 'validate when redirect url is not specified' do
    visit new_oauth_application_path
    within('form[class="new_doorkeeper_application"]') do
      fill_in 'Name', with: 'Sample Application'
      fill_in 'Scopes', with: 'read'
    end
    click_on '登録する'
    assert_text 'フォームにエラーが無いか確認してください'
    assert_text 'を入力してください'
  end

  test 'validate redirect url with invalid value' do
    visit new_oauth_application_path
    within('form[class="new_doorkeeper_application"]') do
      fill_in 'Name', with: 'Sample Application'
      fill_in 'Redirect URL', with: 'invalid_uri'
      fill_in 'Scopes', with: 'read'
    end
    click_on '登録する'
    assert_text 'フォームにエラーが無いか確認してください'
    assert_text 'Redirect urlの値が無効です'
  end
end
