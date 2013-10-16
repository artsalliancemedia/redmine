class AddIsPausedColumn < ActiveRecord::Migration
  def self.up
    add_column :issues, :is_paused, :boolean, :default => false
  end

  def self.down
    remove_column :issues, :is_paused
  end
end