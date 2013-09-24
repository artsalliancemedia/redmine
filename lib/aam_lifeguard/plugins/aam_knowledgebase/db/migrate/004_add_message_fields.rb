class AddMessageFields < ActiveRecord::Migration

  def self.up
    add_column :messages, :manufacturer, :string, :null => ""
    add_index :messages, :manufacturer
		
    add_column :messages, :software_version, :string, :null => ""
    add_index :messages, :software_version
		
    add_column :messages, :firmware_version, :string, :null => ""
    add_index :messages, :firmware_version
		
    add_column :messages, :model, :string, :null => ""
    add_index :messages, :model
  end

  def self.down
    remove_column :messages, :model
    remove_column :messages, :manufacturer
    remove_column :messages, :software_version
    remove_column :messages, :firmware_version
  end

end