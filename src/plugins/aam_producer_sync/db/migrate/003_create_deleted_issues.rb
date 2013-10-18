class CreateDeletedIssues < ActiveRecord::Migration
  def self.up
    create_table :deleted_issues do |t|
      t.string  :uuid
	  t.datetime :deleted_on
    end
  end

  def self.down
    drop_table :deleted_issues
  end
end
