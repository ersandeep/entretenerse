class RanameCrawlerLog < ActiveRecord::Migration
  def self.up
    rename_table :crawlers_log, :crawler_logs
  end

  def self.down
    rename_table :crawler_logs, :crawlers_log
  end
end
