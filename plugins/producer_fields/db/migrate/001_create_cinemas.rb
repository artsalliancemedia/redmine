class CreateCinemas < ActiveRecord::Migration
  def self.up
    create_table :cinemas do |t|
      t.string :name
      t.string :telephone
      t.string :city
      t.string :postcode
      t.string :ip_address
      t.integer :external_id
    end
  end

  def self.down
    drop_table :cinemas
  end
end
