class AddPauses < ActiveRecord::Migration

  def self.up
    create_table :pauses do |t|
      t.integer :issue_id, :null => false
      t.datetime :start_date, :null => false
      t.datetime :end_date
    end
  end

  def self.down
    drop_table :pauses
  end
end