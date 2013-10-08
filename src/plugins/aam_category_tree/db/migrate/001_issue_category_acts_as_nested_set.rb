class IssueCategoryActsAsNestedSet < ActiveRecord::Migration

  def self.up
    add_column :issue_categories, :parent_id, :integer, :null => true
		add_column :issue_categories, :lft, :integer, :null => false, :default => '0'
		add_column :issue_categories, :rgt, :integer, :null => false, :default => '0'

		if IssueCategory.count > 0
			IssueCategory.rebuild!
		end
  end

  def self.down
		remove_column :issue_categories, :parent_id
		remove_column :issue_categories, :lft
		remove_column :issue_categories, :rgt
  end

end
