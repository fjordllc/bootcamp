# frozen_string_literal: true

require 'application_system_test_case'

class WelcomeTest < ApplicationSystemTestCase
  test 'GET /welcome' do
    visit '/welcome'
    assert_equal 'FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='FJORD BOOT CAMP（フィヨルドブートキャンプ）']", visible: false
    assert_selector "meta[name='twitter:title'][content='FJORD BOOT CAMP（フィヨルドブートキャンプ）']", visible: false
  end

  test 'GET /practices' do
    visit '/practices'
    assert_equal '学習内容 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='学習内容']", visible: false
    assert_selector "meta[name='twitter:title'][content='学習内容']", visible: false
  end

  test 'GET /pricing' do
    visit '/pricing'
    assert_equal '料金 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='料金']", visible: false
    assert_selector "meta[name='twitter:title'][content='料金']", visible: false
  end

  test 'GET /training' do
    visit '/training'
    assert_equal '法人利用 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='法人利用']", visible: false
    assert_selector "meta[name='twitter:title'][content='法人利用']", visible: false
  end

  test 'GET /articles' do
    visit '/articles'
    assert_equal 'ブログ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='ブログ']", visible: false
    assert_selector "meta[name='twitter:title'][content='ブログ']", visible: false
  end

  test 'GET /faq' do
    visit '/faq'
    assert_equal 'FAQ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='FAQ']", visible: false
    assert_selector "meta[name='twitter:title'][content='FAQ']", visible: false
  end

  test 'GET /tos' do
    visit '/tos'
    assert_equal '利用規約 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='利用規約']", visible: false
    assert_selector "meta[name='twitter:title'][content='利用規約']", visible: false
  end

  test 'GET /pp' do
    visit '/pp'
    assert_equal 'プライバシーポリシー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='プライバシーポリシー']", visible: false
    assert_selector "meta[name='twitter:title'][content='プライバシーポリシー']", visible: false
  end

  test 'GET /law' do
    visit '/law'
    assert_equal '特定商取引法に基づく表記 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='特定商取引法に基づく表記']", visible: false
    assert_selector "meta[name='twitter:title'][content='特定商取引法に基づく表記']", visible: false
  end

  test 'GET /coc' do
    visit '/coc'
    assert_equal 'アンチハラスメントポリシー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='アンチハラスメントポリシー']", visible: false
    assert_selector "meta[name='twitter:title'][content='アンチハラスメントポリシー']", visible: false
  end
end
