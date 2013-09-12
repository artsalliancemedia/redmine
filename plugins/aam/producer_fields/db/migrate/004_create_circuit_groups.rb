class CreateCircuitGroups < ActiveRecord::Migration
  def self.up
    create_table :circuit_groups do |t|
      t.string :name
    end

    create_table :cinemas_circuit_groups, :id => false do |t|
      t.references :cinema, :null => false
      t.references :circuit_group, :null => false
    end

    # Adding the index can massively speed up join tables. Don't use the unique if you allow duplicates.
    add_index(:cinemas_circuit_groups, [:cinema_id, :circuit_group_id], :unique => true)
  end

  def self.down
    drop_table :circuit_groups
    drop_table :cinemas_circuit_groups
  end
end
