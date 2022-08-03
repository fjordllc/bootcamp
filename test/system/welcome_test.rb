# frozen_string_literal: true

require 'application_system_test_case'

class WelcomeTest < ApplicationSystemTestCase
  test 'GET /welcome' do
    visit '/welcome'
    assert_equal 'FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /practices' do
    visit '/practices'
    assert_equal '学習内容 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /pricing' do
    visit '/pricing'
    assert_equal '料金 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /training' do
    visit '/training'
    assert_equal '法人利用 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /articles' do
    visit '/articles'
    assert_equal 'ブログ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /faq' do
    visit '/faq'
    assert_equal 'FAQ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /tos' do
    visit '/tos'
    assert_equal '利用規約 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /pp' do
    visit '/pp'
    assert_equal 'プライバシーポリシー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /law' do
    visit '/law'
    assert_equal '特定商取引法に基づく表記 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /coc' do
    visit '/coc'
    assert_equal 'アンチハラスメントポリシー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
