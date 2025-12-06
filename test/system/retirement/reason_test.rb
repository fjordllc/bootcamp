# frozen_string_literal: true

require 'application_system_test_case'

class RetirementReasonTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'show all reasons for retirement' do
    visit_with_auth new_retirement_path, 'kananashi'
    assert_text '受講したいカリキュラムを全て受講したから'
    assert_text '学ぶ必要がなくなったから'
    assert_text '他のスクールに通うことにしたから'
    assert_text '学習時間を取ることが難しくなったから'
    assert_text '学ぶ意欲が落ちたから'
    assert_text 'カリキュラムに満足できなかったから'
    assert_text 'スタッフのサポートに満足できなかったから'
    assert_text '学ぶ環境に満足できなかったから'
    assert_text '受講料が高いから'
    assert_text '転職や引っ越しなど環境の変化によって学びが継続できなくなったから'
    assert_text '企業研修で利用をしていて研修期間が終了したため'
  end

  test 'show reasons for retirement only to mentor' do
    visit_with_auth "/users/#{users(:yameo).id}", 'hatsuno'
    assert_no_text '退会理由'
    assert_no_text '受講したいカリキュラムを全て受講したから'
    assert_no_text '学ぶ必要がなくなったから'
    assert_no_text '他のスクールに通うことにしたから'
    assert_no_text '学習時間を取ることが難しくなったから'
    assert_no_text '学ぶ意欲が落ちたから'
  end

  test 'show reasons for retirement only retirement users' do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'komagata'
    assert_no_text '退会理由'
    assert_no_text '受講したいカリキュラムを全て受講したから'
    assert_no_text '学ぶ必要がなくなったから'
    assert_no_text '他のスクールに通うことにしたから'
    assert_no_text '学習時間を取ることが難しくなったから'
    assert_no_text '学ぶ意欲が落ちたから'
  end

  test 'GET /retirement' do
    visit '/retirement'
    assert_equal 'FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
