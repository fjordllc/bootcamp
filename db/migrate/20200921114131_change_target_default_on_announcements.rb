# frozen_string_literal: true

class ChangeTargetDefaultOnAnnouncements < ActiveRecord::Migration[6.0]
  def change
    change_column_default :announcements, :target, from: 0, to: 1
  end
end
