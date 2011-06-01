class AddOccurrencesCountToAttribute < ActiveRecord::Migration
  def self.up
    add_column :attributes, :occurrences_count, :integer
  end

  def self.down
    remove_column :attributes, :occurrences_count
  end
end
