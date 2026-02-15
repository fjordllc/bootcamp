class AddChannelToPairWork < ActiveRecord::Migration[8.1]
  def change
    add_column :pair_works, :channel, :string, default: 'ペアワーク・モブワーク1', null: false
  end
end
