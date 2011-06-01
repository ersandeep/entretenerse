class AddRatingEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :rating, :float, :default => 0, :null => false
    add_column :events, :rated_count, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :events, :rating
    remove_column :events, :rated_count
  end
end
