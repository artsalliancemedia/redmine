class AddMessageIssueJoin < ActiveRecord::Migration

  def self.up  
  create_table :messages_issues, :id => false do |t|
      t.integer :message_id
      t.integer :issue_id
    end
		
		add_index :messages_issues, [:message_id, :issue_id]
	end
	
	 def self.down
    drop_table :messages_issues
  end
	
end