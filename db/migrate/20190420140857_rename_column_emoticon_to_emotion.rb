# frozen_string_literal: true

class RenameColumnEmoticonToEmotion < ActiveRecord::Migration[5.2]
  def change
    rename_column :reports, :emoticon, :emotion
  end
end
