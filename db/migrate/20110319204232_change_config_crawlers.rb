class ChangeConfigCrawlers < ActiveRecord::Migration
  def self.up
    change_column :crawlers, :config, :text, :null => true
  end

  def self.down
    change_column :crawlers, :config, :text, :null => false
  end
end
