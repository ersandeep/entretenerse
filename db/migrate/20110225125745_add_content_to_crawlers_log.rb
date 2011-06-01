class AddContentToCrawlersLog < ActiveRecord::Migration
  def self.up
    add_column :crawlers_log, :content, :text
  end

  def self.down
    remove_column :crawlers_log, :content
  end
end
