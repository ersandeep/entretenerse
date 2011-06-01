class AddRunningCrawlers < ActiveRecord::Migration
  def self.up
    add_column :crawlers, :running, :boolean, :default => false
  end

  def self.down
    remove_column :crawlers, :running
  end
end
