class CreateAttributes < ActiveRecord::Migration
  def self.up
    create_table :attributes do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :attributes
  end
end
