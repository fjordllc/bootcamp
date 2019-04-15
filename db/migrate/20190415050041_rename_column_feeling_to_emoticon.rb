class RenameColumnFeelingToEmoticon < ActiveRecord::Migration[5.2]
  def change
    rename_column :reports, :feeling, :emoticon
  end
end
