class SorceryRememberMe < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :remember_me_token, :string, :default => nil
    add_column :users, :remember_me_token_expires_at, :datetime, :default => nil
    
    add_index :users, :remember_me_token
  end

  def self.down
    remove_index :users, :remember_me_token
    
    remove_column :users, :remember_me_token_expires_at
    remove_column :users, :remember_me_token
  end
end
