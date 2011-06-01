class RemoveLatLongFromPlaces < ActiveRecord::Migration
  def self.up
    remove_column :places, :lat
    remove_column :places, :long
  end

  def self.down
    add_column :places, :lat, :float
    add_column :places, :long, :float
  end
end
