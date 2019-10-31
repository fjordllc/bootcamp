# frozen_string_literal: true

module PracticeHelper
  def display_status_name(status)
    case status
    when "not_complete" then
      "未完"
    when "started" then
      "開始"
    when "complete" then
      "完了"
    end
  end
end
