class AddParentIdCrawlerLog < ActiveRecord::Migration
  def self.up
    add_column :crawler_logs, :parent_id, :integer
  end

  def self.down
    remove_column :crawler_logs, :parent_id
  end
end
