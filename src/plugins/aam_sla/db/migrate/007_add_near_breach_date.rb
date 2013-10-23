class AddNearBreachDate < ActiveRecord::Migration
  def self.up
    add_column :issues, :near_breach_date, :datetime
  end

  def self.down
    remove_column :issues, :near_breach_date
  end
end