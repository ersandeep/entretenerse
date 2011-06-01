class AddEventsCountToAttribute < ActiveRecord::Migration
  def self.up
    add_column :attributes, :events_count, :integer
  end

  def self.down
    remove_column :attributes, :events_count
  end
end
