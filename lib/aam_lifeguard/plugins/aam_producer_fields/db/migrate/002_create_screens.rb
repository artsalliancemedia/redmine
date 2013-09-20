class CreateScreens < ActiveRecord::Migration
  def self.up
    create_table :screens do |t|
      t.string :title
      t.string :uuid
      t.string :identifier
      t.belongs_to :cinema
    end
  end

  def self.down
    drop_table :screens
  end
end
