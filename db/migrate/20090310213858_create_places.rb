class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string :name
      t.string :town
      t.string :state
      t.string :country
      t.float :lat
      t.float :long
      t.string :address
  

      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end
