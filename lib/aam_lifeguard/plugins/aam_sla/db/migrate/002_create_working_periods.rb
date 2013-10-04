class CreateWorkingPeriods < ActiveRecord::Migration
  def self.up
    create_table :working_periods do |t|
      t.string  :day
      t.time    :start_time
      t.time    :end_time
      t.string  :time_zone
    end
  end

  def self.down
    drop_table :working_periods
  end
end
