class AddIssueStatusField < ActiveRecord::Migration

  def self.up
    add_column :issue_statuses, :name_raw, :string, :default => nil
    add_index :issue_statuses, :name_raw
  end

  def self.down
    remove_column :issue_statuses, :name_raw
  end

end