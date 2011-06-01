class AddConfigToCrawlerLog < ActiveRecord::Migration
  def self.up
    add_column :crawler_logs, :config, :text
  end

  def self.down
    remove_column :crawler_logs, :config
  end
end
