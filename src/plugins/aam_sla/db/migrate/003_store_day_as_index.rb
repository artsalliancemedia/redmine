class StoreDayAsIndex < ActiveRecord::Migration
  def self.up
    remove_column :working_periods, :day
    add_column :working_periods, :day, :integer
  end

  def self.down
    remove_column :working_periods, :day
    add_column :working_periods, :day, :string
  end
end