class AddResultCrawlerLog < ActiveRecord::Migration
  def self.up
    add_column :crawler_logs, :result, :text
  end

  def self.down
    remove_column :crawler_logs, :result
  end
end
