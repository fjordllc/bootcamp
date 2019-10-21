# frozen_string_literal: true

require "application_system_test_case"

class SignUpTest < ApplicationSystemTestCase
  test "sign up" do
    visit "/users/new"
    within "form[name=user]" do
      fill_in "user[login_name]", with: "foo"
      fill_in "user[email]", with: "foo@example.com"
      fill_in "user[first_name]", with: "太郎"
      fill_in "user[last_name]", with: "テスト"
      fill_in "user[kana_first_name]", with: "タロウ"
      fill_in "user[kana_last_name]", with: "テスト"
      fill_in "user[password]", with: "testtest"
      fill_in "user[password_confirmation]", with: "testtest"
      select "学生", from: "user[job]"
      select "Mac", from: "user[os]"
      select "自宅", from: "user[study_place]"
      select "未経験", from: "user[experience]"
    end
    click_button "利用規約に同意して参加する"
    assert_text "サインアップメールをお送りしました。メールからサインアップを完了させてください。"
  end

  test "sign up as adviser" do
    visit "/users/new?role=adviser"
    within "form[name=user]" do
      fill_in "user[login_name]", with: "foo"
      fill_in "user[email]", with: "foo@example.com"
      fill_in "user[first_name]", with: "太郎"
      fill_in "user[last_name]", with: "テスト"
      fill_in "user[kana_first_name]", with: "タロウ"
      fill_in "user[kana_last_name]", with: "テスト"
      fill_in "user[password]", with: "testtest"
      fill_in "user[password_confirmation]", with: "testtest"
    end
    click_button "アドバイザー登録"
    assert_text "サインアップメールをお送りしました。メールからサインアップを完了させてください。"
    assert User.find_by(email: "foo@example.com").adviser?
  end

  test "sign up as trainee" do
    visit "/users/new?role=trainee"
    within "form[name=user]" do
      fill_in "user[login_name]", with: "foo"
      fill_in "user[email]", with: "foo@example.com"
      fill_in "user[first_name]", with: "太郎"
      fill_in "user[last_name]", with: "テスト"
      fill_in "user[kana_first_name]", with: "タロウ"
      fill_in "user[kana_last_name]", with: "テスト"
      fill_in "user[password]", with: "testtest"
      fill_in "user[password_confirmation]", with: "testtest"
      select "学生", from: "user[job]"
      select "Mac", from: "user[os]"
      select "自宅", from: "user[study_place]"
      select "未経験", from: "user[experience]"
    end
    click_button "利用規約に同意して参加する"
    assert_text "サインアップメールをお送りしました。メールからサインアップを完了させてください。"
    assert User.find_by(email: "foo@example.com").trainee?
  end
end
