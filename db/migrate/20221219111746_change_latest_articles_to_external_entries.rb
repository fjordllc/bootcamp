class ChangeLatestArticlesToExternalEntries < ActiveRecord::Migration[6.1]
  def change
    rename_table :latest_articles, :external_entries
  end
end
