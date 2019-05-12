# frozen_string_literal: true

require "application_system_test_case"

class WatchesTest < ApplicationSystemTestCase
  test "create new watch for report" do
    login_user "komagata", "testtest"
    visit report_path(reports(:report_1))
    first(".thread-meta .thread-meta__watch__form__action").click
    using_wait_time 5 do
      assert_text "【 作業週1日目 】をウォッチ対象に登録しました。"
    end
  end

  test "destroy watch for report" do
    setup { watches(:report1_watch_kimura) }

    login_user "kimura", "testtest"
    visit report_path(reports(:report_1))
    first(".thread-meta .thread-meta__watch__form__action").click
    using_wait_time 5 do
      assert_text "ウォッチを止めました"
    end
  end
end
