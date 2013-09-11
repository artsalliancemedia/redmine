class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :identifier
      t.string :manufacturer
      t.string :model
      t.string :category
      t.string :software_version
      t.string :firmware_version
      t.string :ip_address
      t.string :uuid
      t.references :deviceable, polymorphic: true
      t.integer :deviceable_id
      t.string  :deviceable_type
    end
  end

  def self.down
    drop_table :devices
  end
end
