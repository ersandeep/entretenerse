class AddDateIndexOnOccurrence < ActiveRecord::Migration
  def self.up
    add_index :occurrences, :date
  end

  def self.down
    remove_index :occurrences, :date
  end
end
