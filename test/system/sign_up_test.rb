# frozen_string_literal: true

require "application_system_test_case"

class SignUpTest < ApplicationSystemTestCase
  test "sign up" do
    WebMock.allow_net_connect!

    visit "/users/new"
    within "form[name=user]" do
      fill_in "user[login_name]", with: "foo"
      fill_in "user[email]", with: "test-#{SecureRandom.hex(16)}@example.com"
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

    fill_stripe_element("4242 4242 4242 4242", "12 / 21", "111", "11122")

    click_button "利用規約に同意して参加する"
    sleep 1
    assert_text "サインアップメールをお送りしました。メールからサインアップを完了させてください。"

    WebMock.disable_net_connect!(
      allow_localhost: true,
      allow: "chromedriver.storage.googleapis.com"
    )
  end

  test "sign up as adviser" do
    visit "/users/new?role=adviser"

    email = "test-#{SecureRandom.hex(16)}@example.com"

    within "form[name=user]" do
      fill_in "user[login_name]", with: "foo"
      fill_in "user[email]", with: email
      fill_in "user[first_name]", with: "太郎"
      fill_in "user[last_name]", with: "テスト"
      fill_in "user[kana_first_name]", with: "タロウ"
      fill_in "user[kana_last_name]", with: "テスト"
      fill_in "user[password]", with: "testtest"
      fill_in "user[password_confirmation]", with: "testtest"
    end
    click_button "アドバイザー登録"
    assert_text "サインアップメールをお送りしました。メールからサインアップを完了させてください。"
    assert User.find_by(email: email).adviser?
  end

  test "sign up as trainee" do
    visit "/users/new?role=trainee"

    email = "test-#{SecureRandom.hex(16)}@example.com"

    within "form[name=user]" do
      fill_in "user[login_name]", with: "foo"
      fill_in "user[email]", with: email
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
    assert User.find_by(email: email).trainee?
  end

  test "form item about job seek is only displayed to students" do
    visit "/users/new"
    assert has_field? "user[job_seeker]", visible: :all
    visit "/users/new?role=adviser"
    assert has_no_field? "user[job_seeker]", visible: :all
    visit "/users/new?role=trainee"
    assert has_no_field? "user[job_seeker]", visible: :all
  end
end
