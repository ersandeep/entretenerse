class RemoveRepeatFromOccurrences < ActiveRecord::Migration
  def self.up
    remove_column :occurrences, :repeat
  end

  def self.down
    add_column :occurrences, :repeat, :boolean
  end
end
