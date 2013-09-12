class AddSlaPriorities < ActiveRecord::Migration

  def self.up
    create_table :sla_priorities do |t|
      t.integer :issue_priority_id, :null => false
      t.integer :seconds
    end
  end

  def self.down
    drop_table :sla_priorities
  end

end