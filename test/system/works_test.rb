# frozen_string_literal: true

require 'application_system_test_case'

class WorksTest < ApplicationSystemTestCase
  test "user can see user's own work" do
    visit_with_auth work_path(works(:work1)), 'kimura'
    assert_text "kimura's app"
  end

  test "user can see other user's work" do
    visit_with_auth work_path(works(:work2)), 'kimura'
    assert_text "hatsuno's app"
    assert_no_text '作品を追加'
  end

  test "show user's profile link" do
    visit_with_auth work_path(works(:work1)), 'kimura'
    assert_link 'kimura', href: "/users/#{users(:kimura).id}"
  end

  test 'create a work' do
    visit_with_auth new_work_path, 'kimura'
    fill_in('work[title]', with: "kimura's app2")
    fill_in('work[repository]', with: 'http://kimurasapp2.com')
    fill_in('work[description]', with: '木村のアプリ2です')
    click_button '登録する'
    assert_text 'ポートフォリオに作品を追加しました'
  end

  test 'vailidaiton error when create a work with thumbnail ' do
    visit_with_auth new_work_path, 'kimura'
    image_path = Rails.root.join('test/fixtures/files/companies/logos/1.jpg')
    attach_file('work[thumbnail]', image_path, make_visible: true)
    click_button '登録する'
    assert_text '入力内容にエラーがありました'
    assert_text 'タイトルを入力してください'
    assert_text '説明を入力してください'
    assert_text 'URLまたはリポジトリを入力してください'
  end

  test 'update my work' do
    visit_with_auth work_path(works(:work1)), 'kimura'
    click_link '内容修正'
    fill_in('work[description]', with: '木村のアプリです。頑張りました')
    click_button '更新する'
    assert_text '作品を更新しました'
  end

  test 'destroy my work' do
    visit_with_auth work_path(works(:work1)), 'kimura'
    accept_confirm do
      click_link '削除'
    end
    assert_text 'ポートフォリオから作品を削除しました'
  end

  test 'admin can update a work' do
    visit_with_auth work_path(works(:work1)), 'komagata'
    click_link '内容修正'
    fill_in('work[description]', with: '木村のアプリです。頑張りました')
    click_button '更新する'
    assert_text '作品を更新しました'
  end

  test 'admin can destroy a work' do
    visit_with_auth work_path(works(:work1)), 'komagata'
    accept_confirm do
      click_link '削除'
    end
    assert_text 'ポートフォリオから作品を削除しました'
  end

  test "user can't update other user's work" do
    visit_with_auth work_path(works(:work2)), 'kimura'
    assert_no_text '内容修正'
  end

  test "user can't destroy other user's work" do
    visit_with_auth work_path(works(:work2)), 'kimura'
    assert_no_text '削除'
  end
end
