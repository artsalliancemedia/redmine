class AddResolutionToIssue < ActiveRecord::Migration

  def self.up
    create_table :issue_resolutions do |t|
      t.integer :project_id, :null => false
      t.string :name
      t.integer :parent_id, :null => true
      t.integer :position
      t.integer :lft, :null => false, :default => '0'
      t.integer :rgt, :null => false, :default => '0'
    end

    add_column :issues, :resolution_id, :integer, :null => true
  end

  def self.down
    remove_column :issues, :resolution_id
    drop_table :issue_resolutions
  end

end
