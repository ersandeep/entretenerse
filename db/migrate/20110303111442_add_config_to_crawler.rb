class AddConfigToCrawler < ActiveRecord::Migration
  def self.up
    add_column :crawlers, :config, :text, :null => false
  end

  def self.down
    remove_column :crawlers, :config
  end
end
