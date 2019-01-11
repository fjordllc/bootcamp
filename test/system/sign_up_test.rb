# frozen_string_literal: true

require "application_system_test_case"

class SignUpTest < ApplicationSystemTestCase
  test "sign up" do
    visit new_user_path
    within "form[name=user]" do
      fill_in "user[login_name]", with: "testuser"
      fill_in "user[password]", with: "testtest"
      fill_in "user[password_confirmation]", with: "testtest"
      fill_in "user[email]", with: "testuser@example.com"
      fill_in "user[first_name]", with: "Jean"
      fill_in "user[last_name]", with: "Valjean"
      attach_file "user[avatar]", Rails.root.join("test/fixtures/files/users/avatars/komagata.jpg")
      fill_in "user[description]", with: "I wanna be programmer."
      select "学生", from: "user[job]"
      select "Mac", from: "user[os]"
      select "フィヨルドブートキャンプオフィス", from: "user[study_place]"
      select "未経験", from: "user[experience]"
      fill_in "user[how_did_you_know]", with: "From google"
      fill_in "user[organization]", with: "Fjord, llc"
      first(".js-nda-action").click
      execute_script "document.querySelector('.nda__action').click();"
      execute_script "document.querySelector('.nda__close').click();"
      click_on "参加する"
    end
    assert_text "サインアップしました。"
  end

  test "failed to sign up" do
    visit new_user_path
    within "form[name=user]" do
      fill_in "user[login_name]", with: "komagata"
      fill_in "user[password]", with: "testtest"
      fill_in "user[password_confirmation]", with: "testtest"
      fill_in "user[email]", with: "testuser@example.com"
      fill_in "user[first_name]", with: "Jean"
      fill_in "user[last_name]", with: "Valjean"
      attach_file "user[avatar]", Rails.root.join("test/fixtures/files/users/avatars/komagata.jpg")
      fill_in "user[description]", with: "I wanna be programmer."
      select "学生", from: "user[job]"
      select "Mac", from: "user[os]"
      select "フィヨルドブートキャンプオフィス", from: "user[study_place]"
      select "未経験", from: "user[experience]"
      fill_in "user[how_did_you_know]", with: "From google"
      fill_in "user[organization]", with: "Fjord, llc"
      first(".js-nda-action").click
      execute_script "document.querySelector('.nda__action').click();"
      execute_script "document.querySelector('.nda__close').click();"
      click_on "参加する"
    end
    assert_text "ユーザー名はすでに存在します"
  end

  test "sign up as adviser" do
    visit new_user_path(role: "adviser")
    within "form[name=user]" do
      fill_in "user[login_name]", with: "testuser"
      fill_in "user[password]", with: "testtest"
      fill_in "user[password_confirmation]", with: "testtest"
      fill_in "user[email]", with: "testuser@example.com"
      fill_in "user[first_name]", with: "Jean"
      fill_in "user[last_name]", with: "Valjean"
      fill_in "user[last_name]", with: "Valjean"
      attach_file "user[avatar]", Rails.root.join("test/fixtures/files/users/avatars/komagata.jpg")
      first(".js-nda-action").click
      execute_script "document.querySelector('.nda__action').click();"
      execute_script "document.querySelector('.nda__close').click();"
      click_on "アドバイザー登録"
    end
    assert has_css?(".user-part.is-adviser")
  end
end
