class AddCrawlers < ActiveRecord::Migration
  def self.up
    create_table :crawlers do |table|
      table.column :name, :string, :null => false
      table.column :home_page, :string, :null => false

      table.timestamps
    end
  end

  def self.down
    drop_table :crawlers
  end
end
