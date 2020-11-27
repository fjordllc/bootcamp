# frozen_string_literal: true

require "test_helper"

class WatchTest < ActiveSupport::TestCase
  test "migrate_date実行後は日報・提出物・イベントの作成者自身がWatch中になる" do
    hatsuno = users(:hatsuno)
    komagata = users(:komagata)
    report = reports(:report_19)
    product = products(:product_11)
    event = events(:event_1)
    Watch.migrate_data
    assert Watch.find_by(user: hatsuno, watchable: report)
    assert Watch.find_by(user: hatsuno, watchable: product)
    assert Watch.find_by(user: komagata, watchable: event)
  end
end
