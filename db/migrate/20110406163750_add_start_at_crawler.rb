class AddStartAtCrawler < ActiveRecord::Migration
  def self.up
    add_column :crawlers, :start_at, :datetime
  end

  def self.down
    remove_column :crawlers, :start_at
  end
end
