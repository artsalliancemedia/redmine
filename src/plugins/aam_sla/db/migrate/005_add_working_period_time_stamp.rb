class AddWorkingPeriodTimeStamp < ActiveRecord::Migration
  def self.up
    add_column :working_periods, :time_stamp, :datetime
  end

  def self.down
    remove_column :working_periods, :time_stamp
  end
end