class AddIssueFields < ActiveRecord::Migration

  def self.up
    add_column :issues, :cinema_id, :integer, :null => false
    add_index :issues, :cinema_id

    add_column :issues, :screen_id, :integer, :null => true
    add_index :issues, :screen_id

    add_column :issues, :device_id, :integer, :null => true
    add_index :issues, :device_id
  end

  def self.down
    remove_column :issues, :cinema_id
    remove_column :issues, :screen_id
    remove_column :issues, :device_id
  end

end