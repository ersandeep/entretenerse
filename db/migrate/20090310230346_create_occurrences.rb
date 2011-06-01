class CreateOccurrences < ActiveRecord::Migration
  def self.up
    create_table :occurrences do |t|
      t.date :date
      t.integer :dayOfWeek
      t.boolean :repeat
      t.datetime :from
      t.datetime :to
     
      t.timestamps
    end
  end

  def self.down
    drop_table :occurrences
  end
end
