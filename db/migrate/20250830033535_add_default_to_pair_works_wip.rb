class AddDefaultToPairWorksWip < ActiveRecord::Migration[6.1]
  def change
    change_column_default :pair_works, :wip, from: nil, to: false
  end
end
