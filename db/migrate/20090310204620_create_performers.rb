class CreatePerformers < ActiveRecord::Migration
  def self.up
    create_table :performers do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :performers
  end
end
