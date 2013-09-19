class AddIssueField < ActiveRecord::Migration

  def self.up
    add_column :issues, :uuid, :string, :default => nil
    add_index :issues, :uuid
  end

  def self.down
    remove_column :issues, :uuid
  end

end