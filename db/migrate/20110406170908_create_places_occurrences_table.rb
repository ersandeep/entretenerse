class CreatePlacesOccurrencesTable < ActiveRecord::Migration
  def self.up
    create_table :occurrences_places, :id => false do |t|
      t.column :place_id, :integer
      t.column :occurrence_id, :integer
    end
  end

  def self.down
    drop_table :occurrences_places
  end
end
