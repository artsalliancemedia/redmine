class AddNearBreach < ActiveRecord::Migration

  def self.up
    add_column :sla_priorities, :near_breach_seconds, :integer
  end

  def self.down
    remove_column :sla_priorities, :near_breach_seconds
  end

end